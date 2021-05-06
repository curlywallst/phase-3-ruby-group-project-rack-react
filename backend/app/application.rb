class Application

  def call(env)
    resp = Rack::Response.new
    req = Rack::Request.new(env)

    if req.path.match(/test/) 
      return [200, { 'Content-Type' => 'application/json' }, [ {:message => "test response!"}.to_json ]]
    elsif req.path.match(/dogs/)
      if req.env["REQUEST_METHOD"] == "POST" # CREATE Dog
        input = JSON.parse(req.body.read)
        owner_id = req.path.split("/owners/").last.split("/dogs").last
        owner = Owner.find_by(id: owner_id)
        dog = owner.dogs.create(name: input["name"])
        return [200, { 'Content-Type' => 'application/json' }, [ dog.to_json ]]
      elsif req.env["REQUEST_METHOD"] == "DELETE" # DELETE Dog
        owner_id = req.path.split("/owners/").last.split("/dogs/").first
        owner = Owner.find_by(id: owner_id)
        dog_id = req.path.split("/owners/").last.split("/dogs/").last
        owner.dogs.delete(Dog.find_by(id: dog_id))
      elsif req.env["REQUEST_METHOD"] == "PATCH" # PATCH
        owner_id = req.path.split("/owners/").last
        owner = Owner.find_by(id: owner_id)
        input = JSON.parse(req.body.read)
        dog_id = req.path.split("/owners/").last.split("/dogs/").last
        dog = owner.dogs.find_by(id: dog_id)
        dog.update(input)
        return [200, { 'Content-Type' => 'application/json' }, [ dog.to_json ]]
      end
    elsif req.path.match(/owners/)
      if req.env["REQUEST_METHOD"] == "POST" # CREATE Owner
        input = JSON.parse(req.body.read)
        owner = Owner.create(name: input["name"])
        return [200, { 'Content-Type' => 'application/json' }, [ owner.to_json({:include => :dogs}) ]]
      else
        if req.path.split("/owners").length == 0 # READ all - owners index page
          return [200, { 'Content-Type' => 'application/json' }, [ Owner.all.to_json({:include => :dogs}) ]]
        else 
          owner_id = req.path.split("/owners/").last #READ 1 - strip path info to capture just the id - params
          owner = Owner.find_by(id: owner_id)
          return [200, { 'Content-Type' => 'application/json' }, [ owner.to_json({:include => :dogs}) ]]
        end
      end
    else
      resp.write "Path Not Found"
    end

    resp.finish
  end

end
