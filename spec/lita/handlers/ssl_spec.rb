require "spec_helper"

describe Lita::Handlers::Ssl, lita_handler: true do
  it { routes_command("csr").to(:no_domain) }

  it "responds with help for a missing domain" do
    send_command("csr")
    expect(replies.last).to eq("Please specify a domain.")
  end

  it { routes_command("csr www.example.com").to(:generate_csr) }

  it "responds with help for a missing domain" do
    send_command("csr *.example.com")
    expect(replies.last).to eq("www_example_com")
  end
end
