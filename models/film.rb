require_relative('../db/sql_runner.rb')

class Film
  attr_accessor :title, :price
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @title = options['title']
    @price = options['price'].to_i
  end

  def save()
    sql = "INSERT INTO films (title, price) VALUES ($1, $2) RETURNING id"
    values = [@title, @price]
    films = Sql_Runner.run(sql, values)[0]
    @id = films['id'].to_i
  end

  def self.delete_all()
    sql = "DELETE FROM films"
    values = []
    Sql_Runner.run(sql, values)
  end

  def self.view_all()
    sql = "SELECT * FROM films"
    values = []
    films = Sql_Runner.run(sql, values)
    return films.map { |film| Film.new(film) }
  end

  def update()
    sql = "UPDATE films SET (title, price) = ($1, $2) WHERE id = $3"
    values = [@title, @price, @id]
    Sql_Runner.run(sql, values)
  end

  def customers_list()
    sql = "SELECT customers.* FROM customers INNER JOIN tickets ON customers.id = tickets.customer_id INNER JOIN film_times ON show_time_id = film_times.id WHERE film_id = $1"
    values = [@id]
    customers = Sql_Runner.run(sql, values)
    return customers.map { |customer| Customer.new(customer) }
  end

  def customer_count()
    customers_list().count
  end

  def show_times()
    sql = "SELECT show_time FROM film_times WHERE film_id = $1 ORDER BY show_time ASC"
    values = [@id]
    all_showtimes = Sql_Runner.run(sql, values)
    all_times = all_showtimes.map { |showtime| Film_Time.new(showtime) }
    return all_times.map { |time| time.show_time }
  end

  # def most_sold()
  #   sql = "SELECT tickets.show_time_id, film_times.show_time FROM tickets INNER JOIN film_time ON show_time_id = film_time.id WHERE film_id = $1"
  #   values = [@id]
  #   films = Sql_Runner.run(sql, values)[0]
  #   total_count = Hash.new(0)
  #   most_sold = films.each { |count| total_count[count] += 1 }
  #   return most_sold.values.max
  # end

#
end
