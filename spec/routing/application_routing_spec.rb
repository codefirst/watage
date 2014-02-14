require "spec_helper"

describe "routes for root" do
  it "routes / to the top controller" do
    expect(get("/")).to route_to("top#index")
  end
end
