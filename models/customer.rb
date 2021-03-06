require_relative('../db/sql_runner.rb')

class Customer
  attr_accessor :name, :funds
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
    @funds = options['funds'].to_i
  end

  def save()
    sql = "INSERT INTO customers (name, funds) VALUES ($1, $2) RETURNING id"
    values = [@name, @funds]
    customers = Sql_Runner.run(sql, values)[0]
    @id = customers['id'].to_i
  end

  def self.delete_all()
    sql = "DELETE FROM customers"
    values = []
    Sql_Runner.run(sql, values)
  end

  def self.view_all()
    sql = "SELECT * FROM customers"
    values = []
    customers = Sql_Runner.run(sql, values)
    return customers.map { |customer| Customer.new(customer) }
  end

  def update()
    sql = "UPDATE customers SET (name, funds) = ($1, $2) WHERE id = $3"
    values = [@name, @funds, @id]
    Sql_Runner.run(sql, values)
  end

  def films_list()
    sql = "SELECT films.* from films INNER JOIN film_times ON films.id = film_times.film_id INNER JOIN tickets ON show_time_id = film_times.id WHERE customer_id = $1"
    values = [@id]
    films = Sql_Runner.run(sql, values)
    return films.map { |film| Film.new(film) }
  end

  def sale(time)
    ticket = Ticket.new({
      'customer_id' => @id,
      'show_time_id' => time.id
      })
    ticket.save()
    @funds -= time.price()
    update()
    # @funds -= film.price
    return ticket
  end

#
end
