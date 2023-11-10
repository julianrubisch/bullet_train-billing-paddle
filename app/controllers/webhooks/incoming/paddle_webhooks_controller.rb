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
    paddle_signature = request.headers["Paddle-Signature"]

    ts_part, h1_part = paddle_signature.split(";")
    _, ts = ts_part.split("=")
    _, h1 = h1_part.split("=")

    signed_payload = "#{ts}:#{request.raw_post}"

    key = ENV["PADDLE_SECRET_KEY"]
    data = signed_payload
    digest = OpenSSL::Digest.new("sha256")

    hmac = OpenSSL::HMAC.hexdigest(digest, key, data)
    verified = hmac == h1

    return verify_params.as_json.transform_values { |value| String(value) } if verified

    raise BulletTrain::Billing::Paddle::Error, "Unable to verify paddle webhook event"
  end

  def verify_params
    params.except(:action, :controller).permit!
  end
end
