require "php_serialize"

class Webhooks::Incoming::PaddleWebhooksController < Webhooks::Incoming::WebhooksController
  def create
    Webhooks::Incoming::PaddleWebhook.create(
      data: verified_event,
      # we can mark this webhook as verified because we authenticated it earlier in this controller.
      verified_at: Time.zone.now
    ).process_async

    render json: {status: "OK"}, status: :created
  rescue BulletTrain::Billing::Paddle::Error
    head :bad_request
  end

  private

  def verified_event
    # verify paddle signature
    data = verify_params.as_json.transform_values { |value| String(value) }

    signature = Base64.decode64(data.delete("p_signature"))

    data_serialized = ::PHP.serialize(data.sort_by { |key, value| key }, true)

    digest = OpenSSL::Digest.new("SHA1")
    pub_key = OpenSSL::PKey::RSA.new(ENV["PADDLE_PUBLIC_KEY"].strip).public_key
    verified = pub_key.verify(digest, signature, data_serialized)

    return data if verified

    raise BulletTrain::Billing::Paddle::Error, "Unable to verify paddle webhook event"
  end

  def verify_params
    params.except(:action, :controller).permit!
  end
end
