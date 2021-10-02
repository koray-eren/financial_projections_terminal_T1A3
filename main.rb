require_relative("Asset")
require_relative("Liability")
require_relative("Assumptions")
require_relative("ObjectStorage")
require("json")
require("tty-prompt")

prompt = TTY::Prompt.new
objects = ObjectStorage.new

test_asset = Asset.new("test", 100, 0, 0.05, 0.05)
objects.store(test_asset)
test_asset2 = Asset.new("test2", 100, 0, 0.05, 0.05)
objects.store(test_asset2)
test_loan = Liability.new("loan1", 1000, 1, 0.03)
objects.store(test_loan)
test_loan2 = Liability.new("loan2", 1000, 0, 0.03)
objects.store(test_loan2)

def add_asset(objects)
    system("clear")
    puts "New Asset\n---------"
    prompt = TTY::Prompt.new
    name = prompt.ask("Name:", required: true)

    value = prompt.ask("Value:") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
    end

    first_year = prompt.slider("First Year (0 = existing):", min: 0, max: Assumptions.years, default: 0)

    growth_rate = prompt.ask("Growth Rate (Decimal: 0.05 = 5% per annum) :") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.default(0.05)
    end

    income_rate = prompt.ask("Income Rate (Decimal: 0.05 = 5% per annum) :") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.default(0.04)
    end

    sale_year = prompt.slider("Sale Year (optional, 0 = none):", min: 0, max: Assumptions.years, default: 0)

    sale_year == 0 ? sale_year = nil : nil

    objects.store(Asset.new(name, value, first_year, growth_rate, income_rate, sale_year) )
    
end

def add_liability(objects)
    system("clear")
    puts "New Liability\n---------"
    prompt = TTY::Prompt.new
    name = prompt.ask("Name:", required: true)

    value = prompt.ask("Value:") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
    end

    first_year = prompt.slider("First Year (0 = existing):", min: 0, max: Assumptions.years, default: 0)

    interest_rate = prompt.ask("Interest Rate (Decimal: 0.05 = 5% per annum) :") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.default(0.05)
    end

    deductible = prompt.yes?("Deductible Loan?") do |q|
        q.default(false)
    end

    principal_repayments = prompt.ask("Principal Repayments Per Annum (optional):") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.default(0)
    end
    
    # name, value, first_year, interest_rate, deductible = false, principal_repayments
    objects.store(Liability.new(name, value, first_year, interest_rate, deductible, principal_repayments) )
    
end

def remove_asset(objects)
    system("clear")
    puts "Remove Asset\n---------"
    puts objects.print_assets
    prompt = TTY::Prompt.new
    index_to_remove = prompt.ask("Select an asset to remove:") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.in("1-#{objects.assets.length}")
        q.convert(:int)
    end
    objects.assets.delete_at(index_to_remove - 1)
end

def remove_liability(objects)
    system("clear")
    puts "Remove Liability\n---------"
    puts objects.print_liabilities
    prompt = TTY::Prompt.new
    index_to_remove = prompt.ask("Select a liability to remove:") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.in("1-#{objects.liabilities.length}")
        q.convert(:int)
    end
    objects.liabilities.delete_at(index_to_remove - 1)
end

def edit_asset(objects)
    system("clear")
    puts "Edit Asset\n---------"
    puts objects.print_assets
    prompt = TTY::Prompt.new
    index_to_remove = prompt.ask("Select an asset to edit:") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.in("1-#{objects.assets.length}")
        q.convert(:int)
    end
    objects.assets.delete_at(index_to_remove - 1)
    add_asset(objects)
end

def edit_liability(objects)
    system("clear")
    puts "Edit Liability\n---------"
    puts objects.print_liabilities
    prompt = TTY::Prompt.new
    index_to_remove = prompt.ask("Select a liability to edit:") do |q|
        q.validate(/\d/, "Invalid value: %{value}, must be a number")
        q.in("1-#{objects.liabilities.length}")
        q.convert(:int)
    end
    objects.liabilities.delete_at(index_to_remove - 1)
    add_liability(objects)
end

def manage_assets(objects)
    manage_assets_exit = false
    while !manage_assets_exit
        prompt = TTY::Prompt.new
        system("clear")
        puts objects.print_assets
        choices = [
            { key: "a", name: "add a new asset", value: :add },
            { key: "r", name: "remove an asset", value: :remove },
            { key: "e", name: "edit an asset", value: :edit },
            { key: "q", name: "quit to previous menu ", value: :quit } ]
        objects.assets.size == 0 ? choices.delete_at(1) : nil
        puts "a - add,  #{objects.assets.size == 0 ? nil : "r - remove,  "}e - edit,  q - quit"
        selection = prompt.expand("Select an option", choices)
    
        case selection
        when :add
            add_asset(objects)
        when :remove
            remove_asset(objects)
        when :edit
            edit_asset(objects)
        when :quit
            manage_assets_exit = true
        end
    end
end

def manage_liabilities(objects)
    manage_liabilities_exit = false
    while !manage_liabilities_exit
        prompt = TTY::Prompt.new
        system("clear")
        puts objects.print_liabilities
        choices = [
            { key: "a", name: "add a new liability", value: :add },
            { key: "r", name: "remove a liability", value: :remove },
            { key: "e", name: "edit a liability", value: :edit },
            { key: "q", name: "quit to previous menu ", value: :quit } ]
        objects.liabilities.size == 0 ? choices.delete_at(1) : nil
        puts "a - add,  #{objects.liabilities.size == 0 ? nil : "r - remove,  "}e - edit,  q - quit"
        selection = prompt.expand("Select an option", choices)
    
        case selection
        when :add
            add_liability(objects)
        when :remove
            remove_liability(objects)
        when :edit
            edit_liability(objects)
        when :quit
            manage_liabilities_exit = true
        end
    end
end

def manage_inputs_menu(objects)
    prompt = TTY::Prompt.new
    input_menu_exit = false
    while !input_menu_exit
        system("clear")
        choices = {"Assets" => 1, "Liabilities" => 2, "Income" => 3, "Expenses" => 4, "Back" => 5}
        menu_selection = prompt.select("Select a category", choices, cycle: true)

        case menu_selection
        when 1 # assets
            manage_assets(objects)
        when 2 # liabilities
            manage_liabilities(objects)
        when 3
            # income
            # display all
            # select: add, remove, (edit), back
        when 4
            # expense
            # display all
            # select: add, remove, (edit), back
        when 5
            input_menu_exit = true
        end
    end
end


system("clear")

main_menu_exit = false
while !main_menu_exit
    system("clear")
    choices = {"Manage Inputs" => 1, "Cashflow Table" => 2, "Assets & Liabilties Table" => 3, "Exit" => 4}
    menu_selection = prompt.select("Welcome! What would you like to do?", choices, cycle: true)

    case menu_selection
    when 1
        manage_inputs_menu(objects)
    when 2
        # cashflow table
    when 3
        #assets & liabilities table
    when 4
        main_menu_exit = true
    end
end



# file = File.open("assets.json", "w")
# file.write(test_asset.to_json)
# file.close

# file = File.read("assets.json")
# testAsset2 = Asset.from_json(file)
# p testAsset2