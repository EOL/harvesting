class FieldsController < ApplicationController
  before_action :authenticate_user!
  def new
    fmt = Format.find(params[:format_id])
    pos = Field.where(format_id: fmt.id).maximum(:position) || 0
    field_name =
      begin
        parser =
          if fmt.excel?
            ExcelParser.new(fmt.get_from,
                            sheet: fmt.sheet, header_lines: fmt.header_lines,
                            data_begins_on_line: fmt.data_begins_on_line)
          elsif fmt.csv?
            CsvParser.new(fmt.get_from,
                          field_sep: fmt.field_sep, line_sep: fmt.line_sep, header_lines: fmt.header_lines,
                          data_begins_on_line: fmt.data_begins_on_line)
          else
            raise "I don't know how to read formats of #{fmt.file_type}!"
          end
        parser.headers[pos]
      rescue
        nil
      end
    mapping =
      if pos.positive?
        Field.where(format_id: fmt.id, position: pos).first.mapping
      else
        # TODO: this should be smarter! This will only work for the taxa file...
        'to_nodes_pk'
      end
    @field = Field.new(format: fmt, position: pos + 1, mapping: mapping, expected_header: field_name)
  end

  def create
    @field = Field.new(field_params)
    if @field.save
      name = @field.expected_header
      name = @field.mapping if name.blank?
      flash[:notice] = I18n.t('fields.flash.created', name: name)
      redirect_to new_format_field_path(format_id: @field.format_id)
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'new'
    end
  end

  def field_params
    params.require(:field)
          .permit(:format_id, :position, :validation, :mapping, :special_handling, :submapping, :expected_header,
                  :unique_in_format, :can_be_empty)
  end
end
