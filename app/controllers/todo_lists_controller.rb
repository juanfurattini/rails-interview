class TodoListsController < ApplicationController
  before_action :find_list, only: %i[show edit update destroy]

  # GET /todolists
  def index
    @todo_lists = TodoList.all
  end

  # GET /todolists/:id
  def show

  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new
  end

  # GET /todo_list/:id/edit
  def edit

  end

  # POST /api/todolists
  def create
    @todo_list = TodoList.new(create_params[:todo_list])

    if @todo_list.save
      redirect_to @todo_list, status: :created, notice: 'List was successfully created.'
    else
      render action: 'new', status: :unprocessable_entity
    end
  end

  # PUT /api/todolist/:id
  def update
    @todo_list.assign_attributes(update_params[:todo_list])

    if @todo_list.save
      redirect_to @todo_list, notice: 'List was successfully updated.'
    else
      render action: 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /api/todolists
  def destroy
    if @todo_list.destroy
      redirect_to action: 'index', notice: 'List was successfully deleted.'
    else
      render action: 'show', status: :unprocessable_entity
    end
  end

  # PUT /todolists/:todo_list_id/complete_tasks
  def complete_tasks
    ListCompleterJob.perform_later(params[:todo_list_id])

    redirect_to action: 'index', notice: 'List was enqueued to complete the tasks.'
  end

  private

  def find_list
    @todo_list = TodoList.find(params[:id])
  end

  def create_params
    params.permit :authenticity_token, :commit, :_method, :id, todo_list: [:name, :commit]
  end

  def update_params
    params.permit :authenticity_token, :commit, :_method, :id, todo_list: [:name, :commit]
  end
end
