require 'rails_helper'

RSpec.describe ListCompleterJob, type: :job do
  include ActiveJob::TestHelper

  before do
    allow(todo_list).to receive(:complete!)
    allow(TodoList).to receive(:find).with(todo_list.id).and_return todo_list
  end

  let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }


  subject(:job) { described_class.perform_later(todo_list.id) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(todo_list.id).on_queue('list_completer')
  end

  it 'complete the list item' do
    perform_enqueued_jobs { job }
    expect(todo_list).to have_received(:complete!).once
  end
end
