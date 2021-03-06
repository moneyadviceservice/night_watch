require 'mail'

module NightWatch
  class Mailer

    def initialize(to, from, failure_report_path, repo_to_validate, ref_baseline, ref_range_to_validate, broken_dependants)
      @to = to
      @from = from
      @failure_report_path = failure_report_path
      @repo_to_validate = repo_to_validate
      @ref_baseline = ref_baseline
      @ref_range_to_validate = ref_range_to_validate
      @broken_dependants = broken_dependants
    end

    def deliver
      mail = Mail.new
      mail.delivery_method :sendmail

      mail.to(to)
      mail.from(from)
      mail.subject(email_subject)
      mail.body(email_body)
      mail.add_file(failure_report_path)

      mail.deliver!
    end

  private

    attr_reader :to, :from, :failure_report_path, :repo_to_validate, :ref_baseline, :ref_range_to_validate, :broken_dependants

    def email_subject
      "Night Watch alert: #{repo_to_validate}, #{ref_range_to_validate}"
    end

    def email_body
      broken_dependants_list = broken_dependants.map { |bd| " - #{bd}" }.join("\n")

%Q{
Night Watch found potential problems with commit(s) "#{ref_range_to_validate}" of "#{repo_to_validate}"

The following dependants changed (when validated against "#{ref_baseline}") :
#{broken_dependants_list}
}
    end

  end
end
