class Api::ProductController < ActionController::API
    
    def productsList
        found = false
        page = params[:page]
        perpage = 5
        offset = (page.to_i - 1) * perpage;
        totrecs = Product.all.count
        tot1 = (totrecs.to_f / perpage)
        totalpage = tot1.ceil

        # @products = Product.limit(perpage).offset(offset)
        @products = Product.includes(:category).limit(perpage).offset(offset)        
        if @products.size > 0
            found = true
        end

        if found
            render json: {
                page: page,
                totpage: totalpage,
                totalrecords: totrecs,
                products: @products.as_json(include: { category: { only: :name } }) 
                # products: @products,

            }, status: :ok
        else   
            render json: { 
                message: 'No record(s) found.'
                }, status: :unprocessable_entity                   
    
        end
    end

    def productsSearch
        found = false
        page = (params[:page] || 1).to_i        
        @key = params[:keyword]
        perpage = 5
        offset = (page.to_i - 1) * perpage;

        base_query = Product.all
        base_query = base_query.filter_by_name(@key) if @key.present?
        totrecs = base_query.count 
        tot1 = (totrecs.to_f / perpage)
        totalpage = tot1.ceil

        @products = base_query.limit(perpage).offset(offset)

        if @products.size > 0
            found = true
        end

        if found
            render json: {
                page: page,
                totpage: totalpage,
                totalrecords: totrecs,
                products: @products,
            }, status: :ok
        else   
            render json: { 
                message: 'No record(s) found.'
                }, status: :unprocessable_entity                   
    
        end
    end

    def getSales
        @sales = Sale.select(:id, :salesamount, :salesdate)         
        render json: @sales.as_json(only: [:salesamount, :salesdate]), status: :ok
    end

end
