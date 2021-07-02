--таблица
DROP TABLE IF EXISTS "public"."users";
DROP SEQUENCE IF EXISTS "public".users_id_seq; 

CREATE SEQUENCE "public".users_id_seq;

CREATE TABLE "public"."users" (
    "id" int4 DEFAULT nextval('users_id_seq'::regclass) NOT NULL,
    "login" varchar(16) COLLATE "default" DEFAULT NULL::character varying,
    "email" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    "status" int2 DEFAULT 1 NOT NULL,
    "password" varchar(64) COLLATE "default" DEFAULT NULL::character varying,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."users" OWNER TO "troll";
ALTER TABLE "public"."users" ADD CONSTRAINT login UNIQUE (login);
ALTER TABLE "public"."users" ADD CONSTRAINT email UNIQUE (email);


CREATE UNIQUE INDEX "users_login_idx" ON "public"."users" USING btree ("login");
CREATE UNIQUE INDEX "users_email_idx" ON "public"."users" USING btree ("email");