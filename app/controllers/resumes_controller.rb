class ResumesController < ApplicationController
  # GET /resumes
  # GET /resumes.xml
  def index
    @resumes = Resume.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resumes }
    end
  end

  # GET /resumes/1
  # GET /resumes/1.xml
  def show
    @resume = Resume.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resume }
    end
  end

  # GET /resumes/new
  # GET /resumes/new.xml
  def new
    @resume = Resume.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resume }
    end
  end

  # GET /resumes/1/edit
  def edit
    @resume = Resume.find(params[:id])
  end

  # POST /resumes
  # POST /resumes.xml
  def create
    @resume = Resume.new(params[:resume])

    respond_to do |format|
      if @resume.save
        flash[:notice] = 'Resume was successfully created.'
        format.html { redirect_to(@resume) }
        format.xml  { render :xml => @resume, :status => :created, :location => @resume }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resumes/1
  # PUT /resumes/1.xml
  def update
    @resume = Resume.find(params[:id])

    respond_to do |format|
      if @resume.update_attributes(params[:resume])
        flash[:notice] = 'Resume was successfully updated.'
        format.html { redirect_to(@resume) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resumes/1
  # DELETE /resumes/1.xml
  def destroy
    @resume = Resume.find(params[:id])
    @resume.destroy

    respond_to do |format|
      format.html { redirect_to(resumes_url) }
      format.xml  { head :ok }
    end
  end
end
