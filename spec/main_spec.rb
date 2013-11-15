describe "Application 'BrewDay'" do

  before do
    @app = UIApplication.sharedApplication
    BrewTemplate.destroy_all
    StepTemplate.destroy_all
  end

  it "creates brew template" do
    bt = BrewTemplate.create(name: "Test Name", info: "Test Info", style: 1)
    bt.save!
    BrewTemplate.all.size.should == 1
  end

  it "creates step templates" do
    bt = BrewTemplate.create!(name: "Test Name", info: "Test Info", style: 1)
    bt.save!
    bt.items = NSSet.setWithArray [StepTemplate.create!(name: "Test Name1", info: "Test Info1", hours: 1, minutes: 1),
                                   StepTemplate.create!(name: "Test Name2", info: "Test Info2", hours: 2, minutes: 2)]
    bt.save!

    bt = BrewTemplate.last
    bt.items.count.should == 2
  end

end
