admin = User.find_by(email: "admin@example.com")

if !admin
    admin = User.new(
    email: "admin@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :admin
    )
    admin.save!
end
[
    "Orange Curry",
    "Belly King"
].each do |store|
    user = User.new( email: "#{store.split.map { |s| s.downcase }.join(".")}@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :seller
    )
    user.save!

    Store.find_or_create_by!(
    name: store, user: user
    )
end

[
    ["Massaman Curry", 66.20],
    ["Risotto with Seafood", 33.45],
    ["Tuna Sashimi", 45.00],
    ["Fish and Chips", 55.50],
    ["Pasta Carbonara", 22.60]
].each do |dish|
    store = Store.find_by(name: "Orange Curry")
    Product.find_or_create_by!(
        title: dish.first, price: dish.last , store: store
    )
end

[
    ["Mushroom Risotto", 10.50],
    ["Caesar Salad", 20.59],
    ["Mushroom Risotto", 33.69],
    ["Tuna Sashimi", 20.58],
    ["Chicken Milanese", 15.22]
].each do |dish|
    store = Store.find_by(name: "Belly King")
    Product.find_or_create_by!(
        title: dish.first, price: dish.last , store: store
    )
end

["Aracelis Weissnat", "Pasquale Wisozk"].each do |buyer|
    email = buyer.split.map { |s| s.downcase }.join(".")
    user = User.find_by(email: email)
    if !user
    user = User.new(
        email: "#{email}@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :buyer
        )
        user.save!
    end
end