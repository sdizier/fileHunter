require 'rubygems'
require 'pp'
module FileHuntr

  class JpgHuntr
  
    require 'exifr'
    
    attr_accessor :path, :save_to, :filters, :ignore_list

    def initialize( path, save_to )
      @path = path
      @save_to = save_to
      @filters = {}
      @ignore_list = {}
    end
    
    def method_missing( id, *args, &block )
      %w{ filter ignore }.each do |method|
        return send( method.to_sym, $1.to_sym, *args ) if id.to_s =~ /^#{ method.to_s }_by_(.*)/
      end
      super
    end
    
    #TODO the following filter and ignore methods I feel can be delegated
    def filter( filter_name, *args )
      @filters[ filter_name ] = args[ 0 ]
      self
    end
    
    def ignore( exception_name, *args )
      @ignore_list[ exception_name ] = args[ 0 ]
      self
    end
    
    def find
      files = Dir.glob( File.join( @path, "**", "*.{jpg,JPG,jpeg,JPEG}") )
      files.each do |image|
        FileUtils.cp( image, @save_to ) if matches?( image )
      end
      return self
    end 
    
    def matches?( image )
      
      exif = EXIFR::JPEG.new( image )
      
      @filters.each_pair do |filter, filter_value|
        return false unless exif.send( filter ).to_s =~ /#{ filter_value }/i
      end
      
      @ignore_list.each_pair do |exception, ignore_value|
        return false if exif.send( exception ).to_s =~ /#{ ignore_value }/i
      end
      
      return true
    end 
    
  end
end

huntr =  FileHuntr::JpgHuntr.new( 
  '/home/slan/Pictures/', 
  '/home/slan/projects/experiments/test' 
)

huntr.filter_by_make( 'sony' ).
  filter_by_date_time_original( "2008" ).
  filter_by_date_time_original("aug").
  find
