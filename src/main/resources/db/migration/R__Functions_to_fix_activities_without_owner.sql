/*
 * 1. Chercher le "user" dont le "username" est "Default Owner"
 * 2. Si le "user" existe, alors on le retourne
 * 3. Sinon on le créer avec le username "Default Owner" et on le retourne
 */

CREATE or REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$ -- Créer ou remplace la fonction
  DECLARE
    defaultOwner "user"%rowtype;
    defaultOwnerUsername varchar(500) := 'Default Owner';
  BEGIN
	  SELECT * INTO defaultOwner FROM "user"
	    WHERE username = defaultOwnerUsername;
	  IF NOT found THEN
	    INSERT INTO "user" (id, username)
	      VALUES (nextval('id_generator'), defaultOwnerUsername);
	    SELECT * INTO defaultOwner FROM "user"
	      WHERE username = defaultOwnerUsername;
	  END IF;
	  RETURN defaultOwner;
  END
$$ LANGUAGE plpgsql;

/*
 * 1. Chercher les activités sans "owner"
 * 2. Attribuer à ses activités le "Default owner"
 * 3. Retourner les lignes modifiées
 */

CREATE or REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
  DECLARE
    defaultOwner "user"%rowtype; 
  BEGIN
	defaultOwner:=get_default_owner();
	return query
	UPDATE activity
	SET owner_id = defaultOwner.id
	WHERE owner_id IS NULL
	returning *;
  END
$$ LANGUAGE plpgsql;