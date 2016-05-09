module Api::V1
  class TransactionsController < BaseController

    before_action :authenticate_user_token!, only: [:verify_scan]

    def index
      @transaction = Transaction.all
      if item_id = params[:item_id]
        @transaction = Transaction.where(item_id: item_id)
      end

      render json: @transaction, status: :ok
    end

    # I'm leaking sensitive user information, auth and api token
    def show
      transaction = Transaction.where(id: params[:id]).first

      if !transaction.empty?
        render json: transaction, status: :ok
      else
        render json: {
          error: "No such transaction; check the user_id",
          status: 400
        }, status: 400
      end
    end

    def create
      transaction = Transaction.new(transaction_params)

      if transaction.save
        render nothing: true, status: 204#, location: user
      else
        render json: transaction.errors, status: 422
      end
    end

    def destroy
      transaction = Transaction.find(params[:id])

      if !transaction.nil?
        Transaction.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such transaction; check the transaction id",
          status: 400
        }, status: 400
      end
    end

    def transaction_detail
      @transaction = Transaction.where("(transactions.seller_id = #{params[:id]} OR transactions.buyer_id = #{params[:id]}) AND (transactions.status != 'Pending' AND transactions.status != 'Denied' AND transactions.status != 'Cancelled')")

      if !@transaction.nil?
        @item = []
        @user = []

        @transaction.each do |t|

          @item.push(Item.where(id: t.item_id).first)

          if t.buyer_id != params[:id].to_i
            @user.push(User.where(id: t.buyer_id).first)
          else
            @user.push(User.where(id: t.seller_id).first)
          end
        end

        render 'api/v1/transactions/transaction_detail', :formats => [:json], :handlers => [:jbuilder], status: 201

        #render :json => {:transaction => transaction, :item => item, :user => user}
      else
        render json: {
          error: "No such transaction; check the user_id",
          status: 400
        }, status: 400
      end
    end

    # Verifying a requested In scan or Out scan and updating the respective
    # users balance
    def verify_scan

      decoded = ""

      if !params[:transactions].nil? && !params[:transactions][:scan].nil? && !params[:transactions][:balance].nil?
        decoded = decode(params[:transactions][:scan].split(''))

        decoded = decoded.split('-')
        current_transaction = Transaction.where(id: decoded[0]).first

        if !current_transaction.nil?
          seller = User.where(id: current_transaction[:seller_id]).first
          transaction_validation = (current_transaction[:seller_id] == decoded[2].to_i) && (current_transaction[:buyer_id] == current_user[:id])

          product = Item.where(id: current_transaction.item_id).first

          if transaction_validation

            if decoded[3] == "inscan" && current_transaction.status != "In Progress" && current_transaction.status != "Completed"

              current_transaction.in_scan_date = DateTime.current

              if product.listing_type == "rent" || product.listing_type == "lease"
                current_transaction.status = "In Progress"
              elsif product.listing_type == "timeoffer"
                length = current_transaction.length.split("-")
                if length[1] == "Flat Rate"
                  current_transaction.status = "Completed"
                else
                  current_transaction.status = "In Progress"
                end
              elsif product.listing_type == "sell"
                product.status = "Sold"
                product.save
                current_transaction.status = "Completed"
              end

              current_transaction.save

              if product.listing_type != "sell"
                length = current_transaction.length.split("-")
                qty = length[0]
                length = length[1]
                price = Price.where(item_id: current_transaction.item_id, timeframe: length).first

                sub_total = price.amount * qty.to_i
              else
                price = Price.where(item_id: current_transaction.item_id).first

                sub_total = price.amount
              end

              seller.balance = seller.balance +  sub_total
              seller.save

              render nothing: true, status: 204

            elsif decoded[3] == 'outscan' && current_transaction.status != "Completed"

              current_transaction.out_scan_date = DateTime.current
              current_transaction.status = "Completed"
              current_transaction.save
              @buyer = User.where(user_id: current_transaction[:buyer_id])
              @seller = User.where(user_id: current_transaction[:seller_id])
              @listing = product
              SendEmailJob.set(wait: 1.seconds).review_later(@buyer, @seller, @listing)

              render nothing: true, status: 204
            else
              render json: {
                error: "Sorry invalid QR code.",
                status: 400
              }, status: 400
            end
          else
            render json: {
              error: "Sorry incorrect QR Code detected.",
              status: 400
            }, status: 400
          end
        else
          render json: {
            error: "Transaction does not exist.",
            status: 400
          }, status: 400
        end
      else
        render json: {
          error: "Sorry, invalid QR code.",
          status: 400
        }, status: 400
      end
    end

    private

      def transaction_params
        params.require(:transactions).permit(:start_date, :end_date,
        :return_date, :item_id, :buyer_id, :scan, :balance)
      end

      def decode(scrambled)

        encoder = ["a", "b", "c", "d", "e", "f", "g", "h",
        "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
        "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9"]

        encoded_JSON = ""

        scrambled.each do |char|
            if char !=  "-"
                position = encoder.index(char) - 8

                if position < 0
                    position = position + 36
                end

                encoded_JSON = encoded_JSON + encoder[position]
            else
                encoded_JSON = encoded_JSON + char
            end
        end

        return encoded_JSON
      end
  end
end
