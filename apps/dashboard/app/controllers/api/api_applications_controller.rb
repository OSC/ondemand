class Api::ApiApplicationsController < ApiController

  def index

    applications = SysRouter.apps.map do | app |
      {
        name: app.name,
        type: app.type,
        token: app.token,
        role: app.role,
        category: app.category,
        subcategory: app.subcategory,
        url: app.url,
        path: app.path,
      }
    end

    render json: { items: applications }

  end

end