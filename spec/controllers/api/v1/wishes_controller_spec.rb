require 'spec_helper'

describe Api::V1::WishesController, type: :controller do
  
  describe "GET #show" do
    before(:each) do
      @wish = FactoryGirl.create :wish
      get :show, id: @wish.id
    end

    it "returns the information about a reporter on a hash" do
      wish_response = json_response[:wish]
      expect(wish_response[:name]).to eql @wish.name
    end

    it "has the user as a embeded object" do
      wish_response = json_response[:wish]
      expect(wish_response[:user][:email]).to eql @wish.user.email
    end

    it { should respond_with 200 }
  end

  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :wish }
    end

    context "when is not receiving any wish_ids parameter" do
      before(:each) do
        get :index
      end
      
      it "returns 4 records from the database" do
        wishes_response = json_response
        expect(wishes_response[:wishes].size).to eq(4)
      end

      it "returns the user object into each wish" do
        wishes_response = json_response[:wishes]
        wishes_response.each do |wish_response|
          expect(wish_response[:user]).to be_present
        end
      end

      it { expect(json_response).to have_key(:meta) }
      it { expect(json_response[:meta]).to have_key(:pagination) }
      it { expect(json_response[:meta][:pagination]).to have_key(:per_page) }
      it { expect(json_response[:meta][:pagination]).to have_key(:total_pages) }
      it { expect(json_response[:meta][:pagination]).to have_key(:total_objects) }

      it { should respond_with 200 }
    end

    context "when wish_ids parameter is sent" do
      before(:each) do
        @user = FactoryGirl.create :user
        3.times { FactoryGirl.create :wish, user: @user }
        get :index, wish_ids: @user.wish_ids
      end

      it "returns just the wishes that belong to the user" do
        wishes_response = json_response[:wishes]
        wishes_response.each do |wish_response|
          expect(wish_response[:user][:email]).to eql @user.email
        end
      end
    end
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        @wish_attributes = FactoryGirl.attributes_for :wish
        api_authorization_header user.auth_token
        post :create, { user_id: user.id, wish: @wish_attributes }
      end

      it "renders the json representation for the wish record just created" do
        wish_response = json_response[:wish]
        expect(wish_response[:name]).to eql @wish_attributes[:name]
      end

      it { should respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_wish_attributes = { name: "Smart TV", price: "Twelve dollars" }
        api_authorization_header user.auth_token
        post :create, { user_id: user.id, wish: @invalid_wish_attributes }
      end

      it "renders an errors json" do
        wish_response = json_response
        expect(wish_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        wish_response = json_response
        expect(wish_response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @wish = FactoryGirl.create :wish, user: @user
      api_authorization_header @user.auth_token
    end

    context "when is successfully updated" do
      before(:each) do
        patch :update, { user_id: @user.id, id: @wish.id,
              wish: { name: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        wish_response = json_response[:wish]
        expect(wish_response[:name]).to eql "An expensive TV"
      end

      it { should respond_with 200 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, { user_id: @user.id, id: @wish.id,
              wish: { price: "two hundred" } }
      end

      it "renders an errors json" do
        wish_response = json_response
        expect(wish_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        wish_response = json_response
        expect(wish_response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @wish = FactoryGirl.create :wish, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, { user_id: @user.id, id: @wish.id }
    end

    it { should respond_with 204 }
  end
end
