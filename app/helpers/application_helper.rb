module ApplicationHelper

  def randomized_header_image
      images = [
        asset_path('hero-bg.jpg'),
        asset_path('hero-images/hero-bg-2.jpg'),
        asset_path('hero-images/hero-bg-3.jpg'),
        asset_path('hero-images/hero-bg-4.jpg'),
        asset_path('hero-images/hero-bg-5.jpg'),
        asset_path('hero-images/hero-bg-6.jpg'),
        asset_path('hero-images/hero-bg-7.jpg'),
        asset_path('hero-images/hero-bg-8.jpg'),
        asset_path('hero-images/hero-bg-9.jpg'),
        asset_path('hero-images/hero-bg-10.jpg'),
        asset_path('hero-images/hero-bg-11.jpg'),
        asset_path('hero-images/hero-bg-12.jpg'),
        asset_path('hero-images/hero-bg-13.jpg')
      ]
      images[rand(images.size)]
  end

  def randomized_internal_header_image
      images = [asset_path('hero-images/internal-bg-1.jpg'),asset_path('hero-images/internal-bg-2.jpg'),asset_path('hero-images/internal-bg-3.jpg'),asset_path('hero-images/internal-bg-4.jpg'),asset_path('hero-images/internal-bg-5.jpg'),asset_path('hero-images/internal-bg-6.jpg')]
      images[rand(images.size)]
  end

end
