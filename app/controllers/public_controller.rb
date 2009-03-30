class PublicController < ApplicationController

  # General Landing Page
  def index
  end

  # Allow visitors to add their Resume
  def add_resume
    @resume = Resume.new(:uri => params[:uri])

    respond_to do |format|
      if @resume.save
        flash[:notice] = 'Resume was successfully created.'
        format.html { redirect_to(:action => 'resume', :id => @resume) }
        format.xml  { render :xml => @resume, :status => :created, :location => @resume }
      else
        flash[:notice]=@resume.errors.collect { |field, error| "#{field}: #{error}" }.join('<br />')
        format.html { render :action => "index" }
        format.xml  { render :xml => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Show an index of all the people found
  def people
    @people = Person.find(:all, :order => 'family_name, given_name')

    respond_to do |format|
      format.html # people.html.erb
      format.xml  { render :xml => @people }
    end
  end

  # Show an index of all the organizations found
  def orgs
    @orgs = Organization.find(:all, :order => 'name ASC')

    respond_to do |format|
      format.html # orgs.html.erb
      format.xml  { render :xml => @orgs }
    end
  end
  
  def org
    @org=Organization.find(params[:id])
    
    respond_to do |format|
      format.html # org.html.erb
      format.xml  { render :xml => @org }
    end
  end
  
  # Allow visitors to view a resume
  def resume
    @resume=Resume.find(params[:id])
    
    respond_to do |format|
      format.html # resume.html.erb
      format.xml  { render :xml => @resume }
    end
  end
  
  def search
  	if request.post? then
	  	search=Resume.search(params[:q])
	  	redirect_to :action => :search, :sq => search
	  end
	  if params[:sq] then
	  	@query=SavedQuery.find(params[:sq])
	  end
  end
  
  def vote
  	@query=SavedQuery.find(params[:sq])
  	if params[:dir] == 'up' then
  		value=1
  	else
  		value=-1
  	end
  	@query.vote(params[:p], value)
  	@query.update_results
  	redirect_to :action => :search, :sq => @query
  end

end
