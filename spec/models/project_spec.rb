require 'rails_helper'

RSpec.describe Project, :type => :model do
  let(:project) { create(:project) }

  describe "attributes" do
    it "has an owner" do
      expect(project).to respond_to(:owner)
    end
    it "has a name" do
      expect(project).to respond_to(:name)
    end
    it "has last_scored" do
      expect(project).to respond_to(:last_scored)
    end

    it "validates the presence of name" do
      expect(build(:project, name: nil)).to be_invalid
    end

    it "validates the presence of owner" do
      expect(build(:project, owner: nil)).to be_invalid
    end
  end

  it 'validates unique owner/name' do
    expect(build(:project, name: project.name, owner: project.owner)).to be_invalid
  end

  describe '#search' do
    it 'returns all matches by owner' do
      match_1 = create(:project, name: 'pajamas', owner: 'banana')
      match_2 = create(:project, name: 'peel', owner: 'banana')
      match_3 = create(:project, name: 'awesome-gem', owner: 'developer')
      results = Project.search('banana')

      expect(results).to include(match_1, match_2)
      expect(results).not_to include(match_3)
    end

    it 'returns all matches by name' do
      match_1 = create(:project, name: 'pajamas', owner: 'banana')
      match_2 = create(:project, name: 'peel', owner: 'banana')
      results = Project.search('pajamas')

      expect(results).to include(match_1)
      expect(results).not_to include(match_2)
    end

    it 'returns all matches by name and owner' do
      match_1 = create(:project, name: 'pajamas', owner: 'banana')
      match_2 = create(:project, name: 'peel', owner: 'banana')
      results = Project.search('peel banana')

      expect(results).not_to include(match_1)
      expect(results).to include(match_2)
    end

    it 'returns all matches by description' do
      match_1 = create(
        :project,
        name: 'pajamas',
        owner: 'banana',
        description: 'this is my awesome project'
      )
      match_2 = create(
        :project,
        name: 'peel',
        owner: 'banana',
        description: 'creates awesome peels'
      )
      results = Project.search('awesome')

      expect(results).to include(match_1, match_2)
    end
  end

  describe '.for_language' do
    before do
      create_list(:project, 3, owner: 'matz', main_language: 'Ruby')
      create_list(:project, 2, owner: 'rich', main_language: 'Clojure')
    end

    context 'when a language argument is given' do
      it 'applies a WHERE query to the collection' do
        expect(Project.for_language('Ruby').size).to eq(3)
      end
    end

    context 'when no language argument is given' do
      it 'performs a noop' do
        rich_projects = Project.where(owner: 'rich')
        scoped_projects = rich_projects.for_language(nil)

        expect(rich_projects).to eq(scoped_projects)
      end
    end
  end
end
