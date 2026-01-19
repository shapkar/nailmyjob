# frozen_string_literal: true

puts "Seeding database..."

# Create system quote templates
puts "Creating quote templates..."

QuoteTemplate.find_or_create_by!(
  name: "Kitchen Remodel",
  template_type: :kitchen,
  is_system: true
) do |template|
  template.line_items_config = QuoteTemplate.kitchen_line_items_config
end

QuoteTemplate.find_or_create_by!(
  name: "Bathroom Remodel",
  template_type: :bathroom,
  is_system: true
) do |template|
  template.line_items_config = QuoteTemplate.bathroom_line_items_config
end

puts "Created #{QuoteTemplate.count} templates"

# Create demo company and user for development
if Rails.env.development?
  puts "Creating demo company and user..."

  company = Company.find_or_create_by!(name: "ABC Remodeling") do |c|
    c.address = "123 Business Ave"
    c.city = "Springfield"
    c.state = "IL"
    c.zip_code = "62701"
    c.phone = "(555) 987-6543"
    c.email = "mike@abcremodeling.com"
    c.license_number = "CON-12345"
    c.default_labor_markup = 30.0
    c.default_material_markup = 20.0
  end

  user = User.find_or_create_by!(email: "demo@nailmyjob.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.first_name = "Mike"
    u.last_name = "Builder"
    u.phone = "(555) 987-6543"
    u.company = company
    u.role = :contractor
  end

  puts "Demo user: demo@nailmyjob.com / password123"

  # Create demo clients
  puts "Creating demo clients..."

  client1 = Client.find_or_create_by!(company: company, email: "sarah@example.com") do |c|
    c.name = "Sarah Chen"
    c.phone = "(555) 123-4567"
    c.address = "847 Oak Street"
    c.city = "Springfield"
    c.state = "IL"
    c.zip_code = "62702"
  end

  client2 = Client.find_or_create_by!(company: company, email: "mike.johnson@example.com") do |c|
    c.name = "Mike Johnson"
    c.phone = "(555) 234-5678"
    c.address = "234 Elm Avenue"
    c.city = "Springfield"
    c.state = "IL"
    c.zip_code = "62703"
  end

  puts "Created #{Client.count} clients"

  # Create demo quotes
  puts "Creating demo quotes..."

  unless company.quotes.exists?(quote_number: "K2601001")
    quote1 = company.quotes.create!(
      user: user,
      client: client1,
      quote_number: "K2601001",
      template_type: :kitchen,
      project_size: :medium,
      project_address: "847 Oak Street",
      project_city: "Springfield",
      project_state: "IL",
      project_zip_code: "62702",
      status: :sent,
      sent_at: 2.days.ago,
      valid_days: 30,
      notes: "Full kitchen gut and remodel. Client wants modern look.",
      timeline_estimate: "4-6 weeks from cabinet delivery",
      terms: company.default_terms,
      payment_terms: company.default_payment_terms
    )

    # Add line items
    template = QuoteTemplate.find_by(template_type: :kitchen, is_system: true)
    template.build_line_items_for_quote(quote1)
    quote1.save!

    # Update some line items with specific values
    quote1.line_items.find_by(category: :cabinets)&.update!(
      description: "Mid-range shaker cabinets, white or gray",
      range_low: 10000,
      range_high: 14000
    )

    quote1.line_items.find_by(category: :countertops)&.update!(
      description: "Quartz counters, mid-range",
      range_low: 3500,
      range_high: 5500
    )

    puts "Created quote for #{client1.name}"
  end

  unless company.quotes.exists?(quote_number: "B2601002")
    quote2 = company.quotes.create!(
      user: user,
      client: client2,
      quote_number: "B2601002",
      template_type: :bathroom,
      project_size: :medium,
      project_address: "234 Elm Avenue",
      project_city: "Springfield",
      project_state: "IL",
      project_zip_code: "62703",
      status: :accepted,
      sent_at: 5.days.ago,
      viewed_at: 4.days.ago,
      accepted_at: 3.days.ago,
      valid_days: 30,
      notes: "Master bathroom remodel. Keep tub, replace shower.",
      timeline_estimate: "2-3 weeks",
      terms: company.default_terms,
      payment_terms: company.default_payment_terms
    )

    # Add line items from bathroom template
    template = QuoteTemplate.find_by(template_type: :bathroom, is_system: true)
    template.build_line_items_for_quote(quote2)
    quote2.save!

    # Create a signed change order
    ChangeOrder.create!(
      quote: quote2,
      co_number: 1,
      description: "Add heated floor tile system",
      amount: 450,
      category: :electrical,
      delays_schedule: false,
      status: :signed,
      signed_at: 2.days.ago,
      signer_name: "Mike Johnson",
      signer_email: "mike.johnson@example.com",
      legal_boilerplate: company.legal_boilerplate,
      signature_data: {
        signature_image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...",
        signed_at: 2.days.ago.iso8601,
        ip_address: "192.168.1.1"
      }
    )

    quote2.update!(approved_changes_total: 450)

    puts "Created quote for #{client2.name} with change order"
  end

  puts "Created #{Quote.count} quotes"
  puts "Created #{ChangeOrder.count} change orders"
end

puts "Seeding complete!"
