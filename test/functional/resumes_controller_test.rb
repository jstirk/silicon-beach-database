require 'test_helper'

class ResumesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:resumes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_resume
    assert_difference('Resume.count') do
      post :create, :resume => { }
    end

    assert_redirected_to resume_path(assigns(:resume))
  end

  def test_should_show_resume
    get :show, :id => resumes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => resumes(:one).id
    assert_response :success
  end

  def test_should_update_resume
    put :update, :id => resumes(:one).id, :resume => { }
    assert_redirected_to resume_path(assigns(:resume))
  end

  def test_should_destroy_resume
    assert_difference('Resume.count', -1) do
      delete :destroy, :id => resumes(:one).id
    end

    assert_redirected_to resumes_path
  end
end
