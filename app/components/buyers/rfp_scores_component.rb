# frozen_string_literal: true

class Buyers::RfpScoresComponent < ViewComponent::Base
  def initialize(current_rfp:)
    @current_rfp = current_rfp
  end

  def scores
    @scores ||= begin
      rfp_scores = ScoreCategory.order(position: :asc).map do |score_category|
        @current_rfp.scores.find_or_initialize_by(score_category_id: score_category.id)
      end
      rfp_scores.first.assign_attributes(value: 100) unless rfp_scores.first.persisted?
      rfp_scores
    end
  end

  def errors
    scores.each_with_object({}) do |score, errors|
      if score.value > scores.first.value
        errors[score.score_category_id] = "#{scores.first.name} must be the highest score"
        errors[scores.first.score_category_id] = "#{scores.first.name} must be the highest score"
      elsif total_score != 100 && score.value != 0
        errors[score.score_category_id] = 'Total must equal 100'
      end
    end
  end

  def total_score
    scores.sum(&:value)
  end
end
