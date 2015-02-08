require "rails_helper"

describe "routes for root", type: :routing do
  it "routes / to the top controller" do
    expect(get("/")).to route_to("top#index")
  end
end
