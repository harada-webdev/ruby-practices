# frozen_string_literal: true

module FileFetchable
  def fetch_files(options)
    target_directory = Pathname(ARGV[0] || '.').join('*')
    files = if options[:all]
              Dir.glob(target_directory, File::FNM_DOTMATCH).sort_by { |file| file.sub(/^\./, '') }
            else
              Dir.glob(target_directory).sort
            end
    options[:reverse] ? files.reverse : files
  end
end
