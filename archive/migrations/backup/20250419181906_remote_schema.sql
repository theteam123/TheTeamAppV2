drop policy "Anyone can create public submitter profiles" on "public"."public_submitters";

create policy "Anyone can create public submitter profiles"
on "public"."public_submitters"
as permissive
for insert
to anon, authenticated
with check (true);



