--таблица
DROP TABLE IF EXISTS "public"."users";
DROP SEQUENCE IF EXISTS "public".users_id_seq; 

CREATE SEQUENCE "public".users_id_seq;
-- ALTER SEQUENCE "users_id_seq" RESTART WITH 1;

CREATE TABLE "public"."users" (
    "id" int4 DEFAULT nextval('users_id_seq'::regclass) NOT NULL,
    "name" varchar(255) COLLATE "default" NOT NULL,
    "surname" varchar(255) COLLATE "default" NOT NULL,
    "status" int2 DEFAULT 1 NOT NULL,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."users" OWNER TO "troll";
ALTER TABLE "public"."users" ADD CONSTRAINT surname UNIQUE (surname);


CREATE UNIQUE INDEX "users_surname_idx" ON "public"."users" USING btree ("surname");