module ApplicationHelper
  def status_badge(status)
    classes = case status.to_sym
    when :overdue
      "bg-red-100 text-red-800"
    when :due_soon
      "bg-yellow-100 text-yellow-800"
    when :upcoming
      "bg-green-100 text-green-800"
    when :not_scheduled
      "bg-gray-100 text-gray-600"
    end
    content_tag(:span, status.to_s.humanize, class: "inline-block px-2 py-0.5 text-xs font-medium rounded-full #{classes}")
  end

  def stock_badge(supply)
    if supply.low_stock?
      content_tag(:span, "Low Stock", class: "inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-red-100 text-red-800")
    else
      content_tag(:span, "In Stock", class: "inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-800")
    end
  end
end
