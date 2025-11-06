module ApplicationHelper
  # SEO Helpers

  # Page title with fallback
  def page_title(title = nil)
    base_title = "PlanMyDay - ADHD-Friendly Productivity App for Freelancers"

    # For native apps, use simpler titles without suffix
    if native_app?
      return title || "PlanMyDay"
    end

    # For web, use full titles with suffix
    title ? "#{title} | PlanMyDay" : base_title
  end

  # Meta description with fallback
  def meta_description(description = nil)
    default = "Stop fighting your brain. PlanMyDay is a productivity app designed specifically for freelancers with ADHD. Limit daily tasks, capture thoughts with brain dump, and stay focused with built-in timers."
    description || default
  end

  # Canonical URL for the current page
  def canonical_url(url = nil)
    url || request.original_url
  end

  # Open Graph meta tags
  def og_meta_tags(title: nil, description: nil, image: nil, url: nil, type: "website")
    tags = []
    tags << tag.meta(property: "og:title", content: title || page_title)
    tags << tag.meta(property: "og:description", content: description || meta_description)
    tags << tag.meta(property: "og:image", content: image || default_og_image)
    tags << tag.meta(property: "og:url", content: url || canonical_url)
    tags << tag.meta(property: "og:type", content: type)
    tags << tag.meta(property: "og:site_name", content: "PlanMyDay")
    safe_join(tags, "\n")
  end

  # Twitter Card meta tags
  def twitter_card_meta_tags(title: nil, description: nil, image: nil)
    tags = []
    tags << tag.meta(name: "twitter:card", content: "summary_large_image")
    tags << tag.meta(name: "twitter:title", content: title || page_title)
    tags << tag.meta(name: "twitter:description", content: description || meta_description)
    tags << tag.meta(name: "twitter:image", content: image || default_og_image)
    safe_join(tags, "\n")
  end

  # Default Open Graph image
  def default_og_image
    # Use absolute URL for OG image
    image_url("founder.jpg")
  end

  # Structured data (JSON-LD) helper
  def structured_data(data)
    content_tag(:script, type: "application/ld+json") do
      data.to_json.html_safe
    end
  end

  # Organization structured data
  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "PlanMyDay",
      "url": "https://planmyday.me",
      "logo": image_url("founder.jpg"),
      "description": "ADHD-friendly productivity app for freelancers",
      "founder": {
        "@type": "Person",
        "name": "Jonathan Buckland"
      }
    }
  end

  # Software Application structured data
  def software_application_schema
    {
      "@context": "https://schema.org",
      "@type": "SoftwareApplication",
      "name": "PlanMyDay",
      "applicationCategory": "ProductivityApplication",
      "operatingSystem": "Web",
      "offers": {
        "@type": "Offer",
        "price": "0",
        "priceCurrency": "USD",
        "description": "Free plan available"
      },
      "description": "ADHD-friendly productivity app designed for freelancers. Features include task limiting, brain dump, pomodoro timer, and gamification.",
      "featureList": [
        "Task Limiting (3-5 tasks per day)",
        "Brain Dump with voice input",
        "Pomodoro Timer",
        "Gamification & XP System",
        "Interruption Tracking"
      ],
      "screenshot": image_url("founder.jpg")
    }
  end

  # Offer structured data for pricing page
  def pricing_offer_schema
    {
      "@context": "https://schema.org",
      "@type": "Offer",
      "name": "PlanMyDay Pro",
      "description": "Full access to PlanMyDay's ADHD-friendly productivity features",
      "price": "5.00",
      "priceCurrency": "USD",
      "priceSpecification": {
        "@type": "UnitPriceSpecification",
        "price": "5.00",
        "priceCurrency": "USD",
        "unitText": "MONTH"
      },
      "seller": {
        "@type": "Organization",
        "name": "PlanMyDay"
      },
      "availability": "https://schema.org/InStock",
      "url": "https://planmyday.me/pricing"
    }
  end

  # FAQ Page structured data
  def faq_page_schema(questions_and_answers)
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": questions_and_answers.map do |qa|
        {
          "@type": "Question",
          "name": qa[:question],
          "acceptedAnswer": {
            "@type": "Answer",
            "text": qa[:answer]
          }
        }
      end
    }
  end
end
