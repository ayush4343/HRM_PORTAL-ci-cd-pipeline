ActiveAdmin.register Organization do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment

  permit_params :email, :company_name, :website, :contact, :activated

  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :company_name, :website, :contact]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do
    selectable_column
    id_column
    column "Company Name", :company_name
    column "Email", :email
    column "Website", :website

    column "Contact", :contact
    column "Status" do |organization|
      if organization.activated?
        status_tag("Active", class: 'ok')
      else
        status_tag("Inactive", class: 'error')
      end
    end
    actions do |organization|
      link_to organization.activated? ? "Deactivate" : "Activate",
              toggle_activation_admin_organization_path(organization),
              method: :put
    end
  end
  member_action :toggle_activation, method: :put do
    if resource.update_column(:activated, !resource.activated)
      redirect_to admin_organizations_path, notice: "Activation status updated successfully."
    end
  end
end
