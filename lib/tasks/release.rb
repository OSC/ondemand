
namespace :release do
  task :zenodo do
    require 'net/http'
    require 'json'

    if ENV['ZENODO_TOKEN'].to_s == '' || ENV['RELEASE_ARCHIVE'].to_s == ''
      raise StandardError.new('environment variables ZENODO_TOKEN and RELEASE_ARCHIVE have to be set')
    end
    token = ENV['ZENODO_TOKEN'].to_s

    uri = URI("https://zenodo.org/api/deposit/depositions?access_token=#{token}")

    data = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Get.new(uri)
      request['Accept'] = 'application/json'
      
      response = http.request(request)

      raise StandardError.new("cannot contact the zenodo server. It responded with #{response.code}") unless response.code.to_i == 200
      
      JSON.parse(response.body)[0]
    end 

    id = data['id']
    uri = URI("https://zenodo.org/api/deposit/depositions/#{id}/files?access_token=#{token}")

    upload_response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Post.new(uri)
      request['Accept'] = 'application/json'
      p = Pathname.new(ENV['RELEASE_ARCHIVE'].to_s)
      request.set_form([['file', File.open(p.to_s)], ['name', p.basename.to_s]], 'multipart/form-data')
      
      response = http.request(request)

      raise StandardError.new("Cannot upload archive. Zenodo Server responded with #{response.code}") unless response.code.to_i == 201
      response
    end

    puts "successfully uploaded #{ENV['RELEASE_ARCHIVE']} to Zenodo's #{id}"
  end
end