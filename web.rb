#!/usr/bin/env ruby

require 'haml'
require 'sinatra'
require 'sinatra/flash'
require 'kiwi_image_tools'

enable :sessions

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  @files = Dir.glob('uploads/*.*').map{|f| File.basename(f)}

  haml :index
end

get '/upload' do
  haml :upload
end

post '/upload' do
  unless params[:file] &&
      (tmpfile = params[:file][:tempfile]) &&
      (name = params[:file][:filename])
    @error = "No file selected"
    return haml(:upload)
  end
  STDERR.puts "Uploading file, original name #{name.inspect}"

  File.open('uploads/'+name, 'w+'){|outfile|
    while blk = tmpfile.read(65536)
      outfile.write(blk)
    end
  }
  flash[:notice] = "Upload complete"
  redirect '/'
end

get '/generate' do
  g = KiwiImageTools::Generator.new(
      :background_color => params[:background_color],
      :logo_image => 'uploads/'+params[:logo_image],
      :photo_image => 'uploads/'+params[:photo_image],
      :special => {:text => params[:special_text],
                   :color => params[:special_color],
                   :size => params[:special_size].to_i },
      :details => {:text => params[:details_text],
                   :color => params[:details_color],
                   :size => params[:details_size].to_i },
      :expires => {:text => params[:expires_text],
                    :color => params[:expires_color],
                    :size => params[:expires_size].to_i },
      :number => {:text => params[:number_text],
                  :color => params[:number_color],
                  :size => params[:number_size].to_i },
      :contact => {:text => params[:contact_text],
                  :color => params[:contact_color],
                  :size => params[:contact_size].to_i },
      :conditions => {:text => params[:conditions_text],
                  :color => params[:conditions_color],
                  :size => params[:conditions_size].to_i}
  )

  g.save_image('public/output.png')

  flash[:notice] = "Image Generated"
  redirect '/'
end

__END__
@@ layout
%html
  %body
    =styled_flash
  #contents
    = yield

@@ index
%a(href="upload")
  %p Upload Files
%ul
  -@files.each do |file|
    %li= file
%form{:action => "/generate"}
  %fieldset
    %ol
      %li
        %label{:for => "background_color"} Background Color:
        %input{:type=>"text", :name=>"background_color", :value => "#b8b2de"}
      %li
        %label{:for => "logo_image"} Logo Image:
        %input{:type=>"text", :name=>"logo_image", :value => "logo.png"}
      %li
        %label{:for => "photo_image"} Photo Image:
        %input{:type=>"text", :name=>"photo_image", :value => "photo.jpg"}
      %li
        %label{:for => "special_text"} Special Text:
        %input{:type=>"text", :name=>"special_text", :value => "Summer"}
      %li
        %label{:for => "special_color"} Special Color:
        %input{:type=>"text", :name=>"special_color", :value => "blue"}
      %li
        %label{:for => "special_size"} Special Size:
        %input{:type=>"text", :name=>"special_size", :value => "58"}
      %li
        %label{:for => "details_text"} Details Text:
        %input{:type=>"text", :name=>"details_text", :value => "The competition"}
      %li
        %label{:for => "details_color"} Details Color:
        %input{:type=>"text", :name=>"details_color", :value => "blue"}
      %li
        %label{:for => "details_size"} Details Size:
        %input{:type=>"text", :name=>"details_size", :value => "32"}
      %li
        %label{:for => "expires_text"} Expires Text:
        %input{:type=>"text", :name=>"expires_text", :value => "Expires 10 June 2012"}
      %li
        %label{:for => "expires_color"} Expires Color:
        %input{:type=>"text", :name=>"expires_color", :value => "black"}
      %li
        %label{:for => "expires_size"} Expires Size:
        %input{:type=>"text", :name=>"expires_size", :value => "18"}
      %li
        %label{:for => "number_text"} Number Text:
        %input{:type=>"text", :name=>"number_text", :value => "Nbr 103452"}
      %li
        %label{:for => "number_color"} Number Color:
        %input{:type=>"text", :name=>"number_color", :value => "black"}
      %li
        %label{:for => "number_size"} Number Size:
        %input{:type=>"text", :name=>"number_size", :value => "18"}
      %li
        %label{:for => "contact_text"} Contact Text:
        %input{:type=>"text", :name=>"contact_text", :size=>100, :value => '23 K-road, Newton, Auckland.  Phone 09-8886767\nor at this address: 24 K-road, Newton, Auckland.  Phone 09-8886767'}
      %li
        %label{:for => "contact_color"} Contact Color:
        %input{:type=>"text", :name=>"contact_color", :value => "black"}
      %li
        %label{:for => "contact_size"} Contact Size:
        %input{:type=>"text", :name=>"contact_size", :value => "18"}
      %li
        %label{:for => "conditions_text"} Conditions Text:
        %input{:type=>"text", :name=>"conditions_text", :size=>100, :value => 'One vote per person.\nVoid where prohibited.\nValid at participating locations only'}
      %li
        %label{:for => "conditions_color"} Conditions Color:
        %input{:type=>"text", :name=>"conditions_color", :value => "red"}
      %li
        %label{:for => "conditions_size"} Conditions Size:
        %input{:type=>"text", :name=>"conditions_size", :value => "18"}
    %input{:type=>"submit", :name=>"Generate"}
%div
  %img(src="output.png?#{Time.now.to_i}")

@@ upload
%form{:action => "/upload", :method=>"post", :enctype=>"multipart/form-data"}
  %input{:type=>"file", :name =>"file"}
  %input{:type=>"submit", :value=>"Upload"}

