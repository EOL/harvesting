class FieldsController < ApplicationController
  def new
    fmt = Format.find(params[:format_id])
    pos = Field.where(format_id: fmt.id).maximum(:position) || 0
    @field = Field.new(format: fmt, position: pos + 1)
  end

  def create
    @field = field.new(field_params)
    @field.field_sep.gsub!(/\\t/, "\t") # TODO: others? Maybe we should just use a picklist. :|
    if @field.save
      flash[:notice] = I18n.t("fields.flash.created", name: @field.represents,
        path: resource_field_path(@field, resource_id: @field.resource_id)).html_safe
      redirect_to [@field.resource, @field]
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render "new"
    end
  end

  def field_params
    params.require(:field).permit(:resource_id, :position, :represents,
      :header_lines, :data_begins_on_line, :file_type, :field_sep, :sheet,
      :utf8, :get_from)
  end
end
