class ReunionsController < ApplicationController
  deserializable_resource :reunion, only: [:create, :update]
  before_action :get_reunion, only: [:show, :update, :destroy, :publish]

  def index
    render jsonapi: Reunion.kept.limit(20)
  end

  def with_soft_delete
    render jsonapi: Reunion.all.limit(20)
  end

  def show
    render jsonapi: @reunion
  end

  def create
    reunion = Reunion.new(reunion_params.except(:duration))
    calculate_reunion_dates(reunion)

    if reunion.save
      render jsonapi: reunion
    else
      render jsonapi_errors: reunion.errors, status: :bad_request
    end
  end

  def update
    @reunion.attributes = reunion_params.except(:duration)
    calculate_reunion_dates(@reunion)
    if @reunion.save
      render jsonapi: @reunion
    else
      render jsonapi_errors: @reunion.errors, status: :bad_request
    end
  end

  def destroy
    @reunion.discard
    render jsonapi: @reunion
  end

  def publish
    if @reunion.publish
      render jsonapi: @reunion
    else
      render jsonapi_errors: @reunion.errors, status: :bad_request
    end
  end

  private

  def get_reunion
    begin
      @reunion = Reunion.find(params[:id])
      render nothing: true, status: :unprocessable_entity if @reunion.discarded?
    rescue ActiveRecord::RecordNotFound
      render nothing: true, status: :not_found
    end
  end

  def reunion_params
    params.require(:data)
          .require(:attributes)
          .permit(:name, :description, :start_date, :end_date, :location, :duration)
  end

  def calculate_reunion_dates(reunion)
    CalculateReunionDatesService.calculate_from({
      reunion: reunion,
      start_date: reunion_params.dig(:start_date).to_s.to_date,
      end_date: reunion_params.dig(:end_date).to_s.to_date,
      duration: reunion_params.dig(:duration).to_i
    })
  end
  
end
