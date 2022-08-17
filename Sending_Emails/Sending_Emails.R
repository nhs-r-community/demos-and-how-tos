#Sending emails directly from R is a useful addition to your automated workflow

# Set Up ------------------------------------------------------------------

#There are 2 bits of set up to do first

#1. If using an @nhs.net account ask your IT department to enable smtp on your account

#2. You need to "tell" R your email address and password 
#   The best practice for doing this is storing them in you .Renviron file

#Run the following code to open the file

usethis::edit_r_environ()

#Then add your credentials

EMAIL_ADDRESS = "name.name@nhs.net"
EMAIL_PASSWORD = "This!s@Pa55word"

#Save and close the file
#These variales can be retrieved using the Sys.getenv() function

# Send an Email -----------------------------------------------------------

#There are a few packages to choose from, below are a couple that have worked for members of the community
#mailR

library(mailR)

#update the to, subject, body and file_path as required

mailR::send.mail(
  from = Sys.getenv("EMAIL_ADDRESS"),
  to   = to,
  subject = subject,
  body = body,
  smtp = list(host.name = "send.nhs.net",
              port = 587,
              user.name = Sys.getenv("EMAIL_ADDRESS"),
              passwd = Sys.getenv("EMAIL_PASSWORD"),
              tls = TRUE),
  authenticate = TRUE,
  send = TRUE,
  attach.files = file_path
)

#If you have java issues with the mailR package then you can try the emayili package

library(emayili)

smtp <- emayili::server(host = "send.nhs.net",
                        port = 587,
                        username = Sys.getenv("EMAIL_ADDRESS"),
                        password = Sys.getenv("EMAIL_PASSWORD"))

#Set up the email; update the to, subject, body and file_path as required

email <- emayili::envelope() %>%
  emayili::Sys.getenv("EMAIL_ADDRESS") %>%
  emayili::to(to) %>%
  emayili::subject(subject) %>% 
  emayili::text(body) %>% 
  emayili::attachment(file_path)

#Send the email

smtp(email, verbose = TRUE)

#Congratulations! You should now be able to send emails from your nhs.net email!
