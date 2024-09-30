class TodoListItemsController < ApplicationController
  before_action :find_list
  before_action :find_list_item, only: %i[show edit update destroy]

  # GET /todolists/:todo_list_id/todos
  def index
    @todo_list_items = @todo_list.todo_list_items
  end

  # GET /todolists/:todo_list_id/todos/:id
  def show

  end

  # GET /todolists/:todo_list_id/todos/new
  def new
    @todo_list_item = TodoListItem.new(todo_list: @todo_list)

    # respond_to :html
  end

  # GET /todolists/:todo_list_id/todos/:id/edit
  def edit

  end

  # POST /todolists/:todo_list_id/todos
  def create
    @todo_list_item = TodoListItem.new(create_params[:todo_list_item])

    if @todo_list_item.save
      redirect_to [@todo_list, @todo_list_item], status: :created, notice: 'List was successfully created.'
    else
      render action: 'new', status: :unprocessable_entity
    end
  end

  # PUT /todolist/:todo_list_id/todos/:id
  def update
    @todo_list_item.assign_attributes(update_params[:todo_list_item])

    if @todo_list_item.save
      redirect_to [@todo_list, @todo_list_item], status: :ok, notice: 'List item was successfully updated.'
    else
      render action: 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /todolist/:todo_list_id/todos/:id
  def destroy
    if @todo_list_item.destroy
      redirect_to action: 'index', status: :ok, notice: 'List item was successfully deleted.'
    else
      render action: 'show', status: :unprocessable_entity
    end
  end

  # PUT /todolists/:todo_list_id/todos/:todo_list_item_id/complete_task
  def complete_task
    @todo_list_item = @todo_list.todo_list_items.find(params[:todo_list_item_id])
    if @todo_list_item.complete!
      redirect_to action: 'index', status: :ok, notice: 'List item was successfully marked as completed.'
    else
      render action: 'show', status: :unprocessable_entity
    end
  end

  private

  def find_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def find_list_item
    @todo_list_item = @todo_list.todo_list_items.find(params[:id])
  end

  def create_params
    params.permit todo_list_item: [:description, :todo_list_id, :commit]
  end

  def update_params
    params.permit todo_list_item: [:description, :todo_list_id, :commit]
  end
end
