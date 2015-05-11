module Lita
  module Handlers
    class Ssl < Handler
      BASE_URL_FOLDER = "ssl"
      BASE_URL = "#{ENV['BASE_DOMAIN']}/#{BASE_URL_FOLDER}"
      BASE_FILE_LOCATION = "ssl"

      route /^csr$/, :no_domain

      def no_domain response
        response.reply("Please specify a domain.")
      end

      route /^csr\s+(.+)/, :generate_csr, help: { "csr DOMAIN" => "Generates a SSL private key and CSR for DOMAIN." }

      def generate_csr response
        domain = response.matches.first.first
        dash_domain = domain.gsub('.', '_').gsub('*', 'STAR')
        system("mkdir -p #{BASE_FILE_LOCATION}/#{dash_domain}")
        command = "openssl req -nodes -newkey rsa:2048 -keyout #{BASE_FILE_LOCATION}/#{dash_domain}/#{dash_domain}.key -out #{BASE_FILE_LOCATION}/#{dash_domain}/#{dash_domain}.csr -subj '/C=US/ST=Utah/O=#{domain}/OU=IT Department/CN=#{domain}'"
        system(command)
        response_body = "#{BASE_URL}/#{dash_domain}.key \n #{BASE_URL}/#{dash_domain}.csr"
        response.reply(response_body)
      end

      http.get "#{BASE_URL_FOLDER}/:file_name", :fetch_certs

      def fetch_certs(request, response)
        file_name = request.env["router.params"][:file_name]
        folder = File.basename(file_name,File.extname(file_name))
        response.body << File.open("#{BASE_FILE_LOCATION}/#{folder}/#{file_name}", File::RDONLY).read
      end
    end

    Lita.register_handler(Ssl)
  end
end
