class Api::ProductController < ActionController::API
    
    def productsList
        found = false
        page = params[:page]
        perpage = 5
        offset = (page.to_i - 1) * perpage;
        totrecs = Product.all.count
        tot1 = (totrecs.to_f / perpage)
        totalpage = tot1.ceil

        @products = Product.includes(:category).limit(perpage).offset(offset)        
        if @products.size > 0
            found = true
        end

        if found

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { 
                    total_prods: totrecs,                
                    action: "prodlist" }.to_json,
                key:     "user-prodlist"
            )
            handle.wait 
    
            render json: {
                page: page,
                totpage: totalpage,
                totalrecords: totrecs,
                products: @products.as_json(include: { category: { only: :name } }) 

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

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { 
                    total_products: totrecs,
                    action: "prodsearch" }.to_json,
                key:     "user-prodsearch"
            )
            handle.wait 
    

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
        
        total_sales_count = Sale.count 

        handle = KAFKA_PRODUCER.produce(
            topic:   "central_events",
            payload: { 
                total_sales: total_sales_count,                
                action: "salesdata" }.to_json,
            key:     "user-salesdata"
        )
        handle.wait 
    
        render json: @sales.as_json(only: [:salesamount, :salesdate]), status: :ok
    end


    def productCategory
        products = Product.joins(:category)
                          .select('products.id, products.descriptions, products.qty, products.unit, 
                                   products.costprice, products.sellprice, 
                                   categories.name as category_name')
      
        grouped = products.group_by(&:category_name).map do |name, details|
          {
            category: name,
            products: details.map { |p| p.attributes.except('category_name') }
          }
        end

        products_count = Product.count

        handle = KAFKA_PRODUCER.produce(
            topic:   "central_events",
            payload: { 
                products_count:  products_count,
                action: "categoryproducts" }.to_json,
            key:     "user-categoryproducts"
        )
        handle.wait 
        

        render json: grouped, status: :ok
      end
      
end
