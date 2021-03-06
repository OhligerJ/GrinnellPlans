require 'spec_helper'

describe PlansController do
  setup :activate_authlogic
  before do
    @account = Account.create! username: 'testaccount', password: '123456', password_confirmation: '123456'
    @plan = Plan.create! account: @account, edit_text: ''
    @account_session = AccountSession.create! @account
  end

  it 'redirects to login when no user present' do
    @account_session.destroy
    get :show, id: @account.username
    assert_redirected_to login_path
  end

  describe 'read plan' do
    before { get :show, id: @account.username }
    subject { response }
    it { should be_success }
    it { should render_template('show') }
    it { assigns(:account).should eq @account }
  end

  describe 'update plan' do
    context 'normal request' do
      before do
        post :update, id: @account.username, plan: { edit_text: 'Foo bar' }
      end
      it 'changes plan contents' do
        @plan.reload.edit_text.should eq 'Foo bar'
      end
      it 'updates changed timestamp' do
        @account.reload.changed_date.should >= Time.now - 5
      end
      it 'redirects to show' do
        assert_redirected_to read_plan_path(id: @account.username)
      end
    end
  end

  describe 'mark_level_as_read' do
    context 'normal request' do
      before do
        interest = Account.create! username: 'acctinterest', password: '123456', password_confirmation: '123456'
        interest2 = Account.create! username: 'acctinterest2', password: '123456', password_confirmation: '123456'
        @account.interests_in_others.create!(interest: interest.id, priority: 1, updated: 1)
        @account.interests_in_others.create!(interest: interest2.id, priority: 2, updated: 1)

        # sanity
        assert_equal 1, @account.interests_in_others.updated.where(priority: 1).count
        assert_equal 1, @account.interests_in_others.updated.where(priority: 2).count

        put :mark_level_as_read, level: '1', return_to: '/'
      end

      it 'should mark all as read for priority one' do
        assert_equal 0, @account.interests_in_others.updated.where(priority: 1).count
      end
      it 'should not mark all as read for priority two' do
        assert_equal 1, @account.interests_in_others.updated.where(priority: 2).count
      end
      it 'redirects to root' do
        assert_redirected_to '/'
      end
    end
  end

  describe 'edit plan'
  describe 'search plan'
  describe 'set_autofinger_level'

end
