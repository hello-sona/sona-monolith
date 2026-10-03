require "rails_helper"

RSpec.describe GoogleCredential do
  let(:payload) do
    {
      "sub" => "google-sub-123",
      "email" => "ada@gmail.com",
      "email_verified" => true,
      "name" => "Ada Lovelace"
    }
  end

  def stub_id_tokens(result)
    allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(result)
  end

  it "returns the payload for a valid token" do
    stub_id_tokens(payload)

    expect(described_class.verify("token")).to eq(payload)
  end

  it "passes the configured client id as the audience" do
    stub_id_tokens(payload)

    described_class.verify("token")

    expect(Google::Auth::IDTokens).to have_received(:verify_oidc)
      .with("token", aud: Rails.configuration.x.google_client_id)
  end

  it "raises NotConfigured when no client id is set" do
    allow(Rails.configuration.x).to receive(:google_client_id).and_return("")

    expect { described_class.verify("token") }
      .to raise_error(described_class::NotConfigured, /not configured/)
  end

  it "rejects an unverified email" do
    stub_id_tokens(payload.merge("email_verified" => false))

    expect { described_class.verify("token") }
      .to raise_error(described_class::Error, "Google email is not verified.")
  end

  it "rejects a payload with no email" do
    stub_id_tokens(payload.merge("email" => ""))

    expect { described_class.verify("token") }
      .to raise_error(described_class::Error, "Invalid Google credential.")
  end

  it "translates a verification failure" do
    allow(Google::Auth::IDTokens).to receive(:verify_oidc)
      .and_raise(Google::Auth::IDTokens::SignatureError, "bad signature")

    expect { described_class.verify("token") }
      .to raise_error(described_class::Error, "Invalid Google credential.")
  end
end
