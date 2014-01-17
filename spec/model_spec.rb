describe "Model 'BrewDay'" do

  before do
    BrewTemplate.destroy_all
  end

  it "creates brew template" do
    bt = BrewTemplate.create(name: "Test Name Brew1", info: "Test Info Brew1", brew_style: 1, position: 0)
    bt.save!
    BrewTemplate.all.size.should == 1
  end

  it "creates group templates" do
    bt = BrewTemplate.create(name: "Test Name Brew1", info: "Test Info Brew1", brew_style: 2, position: 1)
    bt.groups = NSSet.setWithArray [GrpTemplate.create!(name: "Test Name Group1", minutes: 0, position: 0),
                                    GrpTemplate.create!(name: "Test Name Group2", minutes: 10, position: 1)]
    bt.save!
    bt = BrewTemplate.last
    bt.groups.count.should == 2
  end

  it "creates step templates" do
    create_brew

    bt = BrewTemplate.last
    bt.groups.count.should == 2

    gt = GrpTemplate.find_by_name("Test Name Group2")
    gt.steps.count.should == 3
  end

  it "creates brew" do
    bt = create_brew
    b = Brew.brew_builder bt
    b.should.not == nil
  end

  def create_brew
    ctx = App.delegate.managedObjectContext
    bt = BrewTemplate.new(name: "Test Name Brew1", info: "Test Info Brew1", brew_style: 2, position: 2)
    ctx.insertObject(bt)
    bt.save!

    gt1 = GrpTemplate.new(name: "Test Name Group1", minutes: 0, position: 0)
    ctx.insertObject(gt1)
    gt1.brew = bt
    gt1.save!

    gt2 = GrpTemplate.new(name: "Test Name Group2", minutes: 60, position: 1)
    ctx.insertObject(gt2)
    gt2.brew = bt
    gt2.save!

    st1 = StepTemplate.new(name: "Test Name Step1", info: "Test Info Step1", step_type: StepTemplate::STEP_TYPE_EVENT, minutes: 0, position: 0)
    ctx.insertObject(st1)
    st1.group = gt2
    st1.save!

    st2 = StepTemplate.new(name: "Test Name Step2", info: "Test Info Step2", step_type: StepTemplate::STEP_TYPE_ALARM, minutes: 10, position: 1)
    ctx.insertObject(st2)
    st2.group = gt2
    st2.save!

    st3 = StepTemplate.new(name: "Test Name Step3", info: "Test Info Step3", step_type: StepTemplate::STEP_TYPE_TIMER, minutes: 15, position: 2)
    ctx.insertObject(st3)
    st3.group = gt2
    st3.save!

    bt
  end

end
