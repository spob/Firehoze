require File.dirname(__FILE__) + '/../test_helper'

class PeriodicJobTest < ActiveSupport::TestCase

  context "given a job running" do
    setup do
      @job = Factory.create(:run_once_periodic_job, :last_run_at => 1.days.ago,
              :last_run_result => 'Running')
    end

    context "which has been running too long" do
      setup do
        @job.update_attribute(:next_run_at, nil)
      end

      jobs = PeriodicJob.zombies
      should "find a zombie job" do
        assert !jobs.empty?
      end
    end

    context "which has not been running too long" do
      setup do
        @job.update_attribute(:next_run_at, nil)
        @job.update_attribute(:last_run_at, 5.seconds.ago)
      end

      jobs = PeriodicJob.zombies
      should "find no zombie job" do
        assert jobs.empty?
      end
    end
  end

  context "given a job ready to run" do
    setup do
      @job = Factory.create(:run_once_periodic_job)
      @job.update_attribute(:next_run_at, 1.days.ago)
    end

    jobs = PeriodicJob.ready_to_run
    should "find a job ready to run" do
      assert !jobs.empty?
    end
  end

  context "given there are jobs ready to run" do
    setup do
      @run_once_job_null_next_run = Factory.create(:run_once_periodic_job, :last_run_at => 1.days.ago)
      @run_once_job_null_next_run.update_attribute(:next_run_at, nil)

      @run_once_job_future_next_run = Factory.create(:run_once_periodic_job)
      @run_once_job_future_next_run.update_attribute(:next_run_at, 5.seconds.since)

      @run_once_job_past_next_run = Factory.create(:run_once_periodic_job)
      @run_once_job_past_next_run.update_attribute(:next_run_at, 5.seconds.ago)
    end

    should "run successfully" do
      jobs = PeriodicJob.find_jobs_to_run
      assert !jobs.empty?
      assert_equal 1, jobs.size
      assert !jobs.include?(@run_once_job_null_next_run)
      assert !jobs.include?(@run_once_job_future_next_run)
      assert jobs.include?(@run_once_job_past_next_run)

      assert_nothing_raised {
        @run_once_job_past_next_run.run!
        PeriodicJob.run_jobs
      }

      PeriodicJob.cleanup
    end

    context "when executing list method" do
      should "return rows" do
        assert !PeriodicJob.list(1, 10).empty?
      end
    end

    should "not allow delete" do
      for job in PeriodicJob.list(1, 100)
        assert !job.can_delete?
      end
    end
  end

  context "given a job that errors when running" do
    setup do
      @job = Factory.create(:run_once_periodic_job, :job => "1/0")
      @job.update_attribute(:next_run_at, 5.seconds.ago)
    end

    should "fail gracefully" do
      assert_nothing_raised {
        assert_nil @job.last_run_result
        @job.run!
        assert_not_equal "Pending", @job.last_run_result
        assert_not_equal "OK", @job.last_run_result
        assert_not_nil @job.last_run_result =~ /could not run/
      }
    end
  end



  context "testing run date calculations" do
    should "return nil next run date" do
      assert_nil PeriodicJob.new.calc_next_run
    end

    should "set next run date to now" do
      job = RunOncePeriodicJob.create
      assert_not_nil job
      assert job.next_run_at < Time.zone.now + 10.seconds
      assert job.next_run_at > Time.zone.now - 10.seconds
    end
  end

  context "given an interval job that runs every 30 minutes" do
    setup do
      @job = Factory.create(:run_interval_periodic_job, :last_run_at => 5.minutes.ago)
      @job.update_attribute(:next_run_at, nil)
      @next_job = @job.calc_next_run
      @next_job.save
    end

    should "calculate next interval" do
      # within a second
      assert @next_job.next_run_at.between?(Time.zone.now + 29, Time.zone.now + 31)
      assert_equal @job.interval, @next_job.interval
      assert_equal @job.job, @next_job.job
    end
  end

  context "given a run at job" do
    setup do
      @job = Factory.create(:run_at_periodic_job)
      # set current time to 13:00 PM
      @now = Time.parse("13:00")
      @job.set_now @now
    end

    context "which is yet to run today" do
      setup do
        # set job to run at 13:30 AM
        @job.update_attribute(:run_at_minutes, 13*60+30)
        @next_job = @job.calc_next_run
        @next_job.save
      end

      should "calculate a next run of today" do
        assert_equal Time.local(@now.year,
                @now.month,
                @now.day,
                13, 30, 0), @next_job.next_run_at
      end
    end

    context "which has already run today" do
      setup do
        # set job to run at 12:30 PM
        @job.update_attribute(:run_at_minutes, 12 * 60 + 30)
        @next_job = @job.calc_next_run
        @next_job.save
      end

      should "calculate a next run of the next day" do
        @tomorrow = @now + 1.day
        assert_equal Time.local(@tomorrow.year,
                @tomorrow.month,
                @tomorrow.day,
                12, 30, 0), @next_job.next_run_at
      end
    end
  end

  private

  def calc_next_interval interval
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    hours = Time.zone.now.hour
    minutes = Time.zone.now.min + interval
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    if minutes >= 60
      hours += 1
      minutes = minutes - 60
    end
    Time.zone.parse("#{"%02d" % hours}:#{"%02d" % minutes}")
  end
end