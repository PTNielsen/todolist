require './db/setup'
require './lib/all'
require 'date'
require 'pry'

class ToDoList

  attr_reader :logged_on

  def login
    print "Please enter your username: "
    user_name = gets.chomp
    @logged_on = User.where(name: user_name).first
      if @logged_on
        puts "Welcome back, #{@logged_on.name}!"
      else
        @logged_on = User.create! name: user_name
        puts "Hello, #{@logged_on.name}!"
      end
  end
  
  def take_command
    print "Would you like to add a task, view your current To Do List, or search for a keyword? (add/view/search): "
    user_input = gets.chomp
      if user_input == "add"
        add_task
      elsif user_input == "view"
        view_list
      elsif user_input == "search"
        search_tasks
      else
        puts "Invalid command."
        take_command
      end
  end

  def add_task
    print "What do you need to do?: "
    item_to_do = gets.chomp
    print "Ok! When does it need to be completed by? (YYYY-MM-DD): "
    due_date = gets.chomp
    t = Task.create!(user_id: @logged_on.id, task: item_to_do, due_date: Date.parse(due_date), completed: false)
    t.save
    puts "It's been added to your To Do List!"
    done?
  end

  def list_all
    Task.where(user_id: @logged_on.id)
  end

  def view_list
    if Task.where(user_id: @logged_on.id, completed: false).count == 0
      puts "You have no tasks on your To Do List!  Would you like to add one? (y/n): "
      add_new = gets.chomp
      if add_new == "y"
        add_task
      elsif add_new == "n"
        puts "Sounds good!"
        done?
      else
        puts "Invalid command."
        view_list
      end
    else
      view_tasks = Task.where(user_id: @logged_on.id, completed: false)
      view_tasks.each do |t|
        puts "Task ID - #{t.id}\n User ID - #{t.user_id}\n Task - #{t.task}\n Due Date - #{t.due_date}\n Completed? - #{t.completed}\n Time Created - #{t.created_at}"
      end
      print "Would you like to cross an item off your To Do List? (y/n): "
      request_change = gets.chomp
        if request_change == "y"
          change_status
        elsif request_change == "n"
          puts "Sounds good!"
          done?
        else
          puts "Invalid command."
          view_list
        end
      end
  end

  def change_status
    print "What is the ID Number of the task you completed?: "
    task_id_number = gets.chomp
    completed_task = Task.where(id: task_id_number)
      if completed_task
        Task.find(task_id_number).update(completed: true)
        puts "Your task has been updated as completed!"
        done?
      else
        puts "ID Number not recognized."
        change_status
      end
  end

  def search_tasks
    print "What term would you like to search for?: "
    search_term = gets.chomp
    express_search = Task.where(user_id: @logged_on.id).where("task LIKE ?", "%#{search_term}%")
    express_search.each do |exp|
      puts "Task ID - #{exp.id}\n User ID - #{exp.user_id}\n Task - #{exp.task}\n Due Date - #{exp.due_date}\n Completed? - #{exp.completed}\n Time Created - #{exp.created_at}"
    end
    done?
  end

  def done?
    print "Would you like to do anything else? (y/n): "
    done = gets.chomp
      if done == "y"
        take_command
      elsif done == "n"
        puts "OK! Get to work!"
        exit
      else
        puts "Invalid command."
        done?
      end
  end

end

list = ToDoList.new

list.login
list.take_command