require 'spec_helper'
require 'awesome_print'


describe "Requests to /photos.json" do
  let(:invalid_user){ build(:user, email: nil) }

  context :upload do
    before :each do
      @user = create(:user)
      @file = fixture_file_upload("#{Rails.root}/spec/fixtures/files/image.jpg", 'image/jpeg')
    end

    it "with right token it's upload file" do
      post( photos_path(format: :json), {token: @user.token, photo: @file})

      expect(response).to be_success
      expect(response.body.blank?).to_not be_true
      json = JSON.parse(response.body)
      expect(json['status']['code']).to eq(200)
      expect(json['photo']['id']).to be_present
      expect(json['photo']['image']['thumb']).to be_present
      expect(json['photo']['image']['full']).to be_present
    end

    it "with wrong token it's finish with 404 error" do
      post( photos_path(format: :json), {token: 'IMGRY_WRONG_TOKEN', photo: @file})

      expect(response).to be_success
      expect(response.body.blank?).to_not be_true
      json = JSON.parse(response.body)
      expect(json['status']['code']).to eq(404)
    end

    it "with right token but empty file it's finish with 500 error" do
      post( photos_path(format: :json), {token: @user.token, photo: nil})

      expect(response).to be_success
      expect(response.body.blank?).to_not be_true
      json = JSON.parse(response.body)
      expect(json['status']['code']).to eq(500)
    end
  end

  context :feed do
    before :each do
      @file   = fixture_file_upload("#{Rails.root}/spec/fixtures/files/image.jpg", 'image/jpeg')
      @photos = create_list(:photo, 5, image: @file)
    end

    it "get limited photos" do
      get(photos_path(format: :json), {limit: 2})
      expect(response).to be_success
      expect(response.body).to be_present
      json = JSON.parse(response.body)
      expect(json['photos'].length).to eq(2)
    end

    it "get limited photos to up direction" do
      get(photos_path(format: :json), {limit: 2, from: @photos[1].id, direction: 'up'})
      expect(response).to be_success
      expect(response.body).to be_present
      json = JSON.parse(response.body)
      expect(json['photos'].length).to eq(2)
      expect(json['photos'][0]['id']).to eq(@photos[2].id)
      expect(json['photos'][1]['id']).to eq(@photos[3].id)
    end

    it "get limited photos to down direction" do
      get(photos_path(format: :json), {limit: 2, from: @photos[2].id, direction: 'down'})
      expect(response).to be_success
      expect(response.body).to be_present
      json = JSON.parse(response.body)
      expect(json['photos'].length).to eq(2)
      expect(json['photos'][0]['id']).to eq(@photos[1].id)
      expect(json['photos'][1]['id']).to eq(@photos[0].id)
    end

  end

end