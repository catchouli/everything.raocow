class CategoriesController < ApplicationController

  before_filter :authenticate_user!, only: [:new, :create, :edit, :update]
  before_filter :authenticate_admin, only: [:destroy]
  before_filter :set_cat_type,       except: [:create]
  before_filter :category_exists,    except: [:index, :new, :create]

  helper_method :category_path
  helper_method :edit_category_path
  helper_method :new_category_path
  helper_method :categories_path
  helper_method :category_videos_path

  helper_method :category_url
  helper_method :edit_category_url
  helper_method :new_category_url
  helper_method :categories_url
  helper_method :category_videos_url

  def index
    @categories = Category.where(cat_type: Category.cat_types[@cat_type]).
                           paginate(page: params[:page])
  end

  def show
    @videos = @category.videos.paginate(page: params[:page],
                                       per_page: 20).order('published_at DESC')
  end

  def new
    @category = Category.new

    # Save cat_type
    session[:cat_type] = @cat_type
  end

  def create
    # Restore cat_type
    @cat_type = session[:cat_type]

    @category = Category.new(category_params.merge({cat_type: @cat_type}))

    if @category.save
      flash[:success] = "#{@cat_type} #{@category.name} added"
      redirect_to categories_path
    else
      render 'new'
    end
  end

  def edit
    @videos = Video.all
  end

  def update

    videos = (params["category"]["video_ids"] - [""]).map{ |c| c.to_i }

    Categorisation.where(category_id: category.id).delete_all

    Categorisation.create(videos.map { |v| { category_id: category.id, video_id: v } })

    redirect_to category_path(category)
  end

  def destroy
    @category.destroy if @category

    redirect_to action: :index
  end

  private

    def category_exists
      @category = Category.find_by_id(params[:id])

      if @category == nil
        flash[:error] = "No such category #{params[:id]}"
        redirect_to categories_url
      end
    end

    def category_params
      params.require(:category).permit(:name)
    end

    def cat_type

      if params.has_key?(:cat_type)
        return params[:cat_type]
      else
        return "category"
      end
    end

    def set_cat_type
      @cat_type = cat_type

      unless Category.cat_types.has_key?(cat_type)
        flash.now[:error] = "Invalid category type: #{cat_type}"
        @cat_type = "category"
      end      
    end

    # route function overrides
    def category_videos_path(id)
      if @cat_type == "category"
        return super(id)
      end

      return send("#{@cat_type}_videos_path", id)
    end

    def categories_path
      if @cat_type == "category"
        return super
      end

      if @cat_type.pluralize(0) == @cat_type
        return send("#{@cat_type}_index_path")
      else
        return send("#{@cat_type.pluralize(0)}_path")
      end
    end

    def new_category_path
      if @cat_type == "category"
        return super
      end

      return send("#new_{@cat_type}_path")
    end

    def edit_category_path(id)
      if @cat_type == "category"
        return super(id)
      end

      return send("edit_#{@cat_type}_path", id)
    end

    def category_path(id)
      if @cat_type == "category"
        return super(id)
      end

      return send("#{@cat_type}_path", id)
    end

    def category_videos_url(id)
      if @cat_type == "category"
        return super(id)
      end

      return send("#{@cat_type}_videos_url", id)
    end

    def categories_url
      if @cat_type == "category"
        return super
      end

      if @cat_type.pluralize(0) == @cat_type
        return send("#{@cat_type}_index_url")
      else
        return send("#{@cat_type.pluralize(0)}_url")
      end
    end

    def new_category_url
      if @cat_type == "category"
        return super
      end

      return send("#new_{@cat_type}_url")
    end

    def edit_category_url(id)
      if @cat_type == "category"
        return super(id)
      end

      return send("edit_#{@cat_type}_url", id)
    end

    def category_url(id)
      if @cat_type == "category"
        return super(id)
      end

      return send("#{@cat_type}_url", id)
    end
end