class FieldsController < ApplicationController
  def new
    fmt = Format.find(params[:format_id])
    pos = Field.where(format_id: fmt.id).maximum(:position) || 0
    mapping =
      if pos > 0
        Field.where(format_id: fmt.id, position: pos).first.mapping
      else
        # TODO: this should be smarter! This will only work for the taxa file...
        "to_nodes_pk"
      end
    @field = Field.new(format: fmt, position: pos + 1, mapping: mapping)
  end

  def create
    @field = Field.new(field_params)
    if @field.save
      name = @field.expected_header
      name = @field.mapping if name.blank?
      flash[:notice] = I18n.t("fields.flash.created", name: name)
      redirect_to new_format_field_path(format_id: @field.format_id)
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render "new"
    end
  end

  def field_params
    params.require(:field).permit(:format_id, :position, :validation,
      :mapping, :special_handling, :submapping, :expected_header,
      :unique_in_format, :can_be_empty)
  end
end
