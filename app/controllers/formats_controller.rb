class FormatsController < ApplicationController
  def show
    @format = Format.find(params[:id])
  end

  def new
    resource = Resource.find(params[:resource_id])
    pos = Format.where(resource_id: resource.id).maximum(:position) || 0
    @format = Format.new(resource: resource, position: pos + 1, utf8: true,
      data_begins_on_line: 2)
  end

  def edit
    @format = Format.find(params[:id])
  end

  def create
    @format = Format.new(format_params)
    @format.field_sep.gsub!(/\\t/, "\t") # TODO: others? Maybe we should just use a picklist. :|
    if @format.save
      flash[:notice] = I18n.t("formats.flash.created", name: @format.represents,
        path: resource_format_path(@format, resource_id: @format.resource_id)).html_safe
      redirect_to [@format.resource, @format]
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render "new"
    end
  end

  def update
    @format = Format.find(params[:id])
    # TODO: others? Maybe we should just use a picklist. :| ALSO GENERALIZE WITH EDIT
    format_params[:field_sep].gsub!(/\\t/, "\t")
    if @format.update(format_params)
      flash[:notice] = I18n.t("formats.flash.edited", name: @format.represents,
        path: resource_format_path(@format, resource_id: @format.resource_id)).html_safe
      redirect_to [@format.resource, @format]
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render "new"
    end
  end

  def format_params
    params.require(:format).permit(:resource_id, :position, :represents,
      :header_lines, :data_begins_on_line, :file_type, :field_sep, :sheet,
      :utf8, :get_from)
  end

  def destroy
    @format = Format.find(params[:id])
    name = @format.represents
    resource = @format.resource
    @format.destroy
    redirect_to resource, notice: I18n.t("formats.flash.destroyed", name: name)
  end
end
