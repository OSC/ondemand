
namespace :release do
  task :zenodo do
    require 'net/http'
    require 'json'

    if ENV['ZENODO_TOKEN'].to_s == '' || ENV['RELEASE_ARCHIVE'].to_s == ''
      raise StandardError.new('environment variables ZENODO_TOKEN and RELEASE_ARCHIVE have to be set')
    end
    token = ENV['ZENODO_TOKEN'].to_s
    host = 'zenodo.org'
    port = '443'

    data = Net::HTTP.start(host, port, :use_ssl => true) do |http|
      request = Net::HTTP::Get.new(URI("https://zenodo.org/api/deposit/depositions?access_token=#{token}"))
      request['Accept'] = 'application/json'
      
      response = http.request(request)

      raise StandardError.new("cannot contact the zenodo server. It responded with #{response.code}") unless response.code.to_i == 200
      
      JSON.parse(response.body)[0]
    end 

    id = data['id']

    Net::HTTP.start(host, port, :use_ssl => true) do |http|
      # upload the new archive
      request = Net::HTTP::Post.new(URI("https://zenodo.org/api/deposit/depositions/#{id}/files?access_token=#{token}"))
      request['Accept'] = 'application/json'
      p = Pathname.new(ENV['RELEASE_ARCHIVE'].to_s)
      request.set_form([['file', File.open(p.to_s)]], 'multipart/form-data')
      response = http.request(request)
      raise StandardError.new("Cannot upload archive. Zenodo Server responded with #{response.code}:#{response.body}") unless response.code.to_i == 201


      # TODO remove the existing file

      # edit the metadata to reflect new publish date and new version
      version = /ondemand-(.+).zip/.match(p.basename.to_s)[1]
      uri = URI("https://zenodo.org/api/deposit/depositions/#{id}?access_token=#{token}")
      # uri = URI("https://zenodo.org/api/deposit/depositions/#{id}/actions/edit?access_token=#{token}")
      request = Net::HTTP::Put.new(uri)
      request.set_form_data("metadata" => {"version" => "#{version}-1", "publication_date" => Date.today})
      response = http.request(request)
      puts response.body
      raise StandardError.new("Cannot edit new version. Zenodo Server responded with #{response.code}:#{response.body}") unless response.code.to_i == 201
    end

    uri = URI("#{data['links']['publish']}?access_token=#{token}")
    
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Post.new(uri)
      request['Accept'] = 'application/json'
      
      response = http.request(request)

      raise StandardError.new("Cannot publish archive. Zenodo Server responded with #{response.code}:#{response.body}") unless response.code.to_i == 202
    end

    puts "sucessfully published #{ENV['RELEASE_ARCHIVE']} to zendo at #{data['doi_url']}"
  end
end