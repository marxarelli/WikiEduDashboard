require 'rails_helper'
require "#{Rails.root}/lib/importers/view_importer"

describe ViewImporter do
  describe '.update_views_for_article' do
    it 'should not fail if there are no revisions for an article' do
      VCR.use_cassette 'article/update_views_for_article' do
        article = create(:article,
                         id: 1,
                         title: 'Selfie',
                         namespace: 0,
                         views_updated_at: '2015-01-01')

        # Course and article-course are also needed.
        create(:course,
               id: 10001,
               start: Date.today - 1.week,
               end: Date.today + 1.week)
        create(:articles_course,
               id: 1,
               course_id: 10001,
               article_id: 1)

        ViewImporter.update_views_for_article(article, true)
        ViewImporter.update_views_for_article(article)
      end
    end
  end

  describe '.update_all_views' do
    it 'should get view data for all articles' do
      VCR.use_cassette 'article/update_all_views' do
        # Try it with no articles.
        ViewImporter.update_all_views

        # Add an article
        create(:article,
               id: 1,
               title: 'Wikipedia',
               namespace: 0,
               views_updated_at: Date.today - 2.days)

        # Course, article-course, and revision are also needed.
        create(:course,
               id: 10001,
               start: Date.today - 1.week,
               end: Date.today + 1.week)
        create(:articles_course,
               id: 1,
               course_id: 10001,
               article_id: 1)
        create(:revision,
               article_id: 1)

        # Update again with this article.
        ViewImporter.update_all_views
      end
    end
  end

  describe '.update_new_views' do
    it 'should get view data for new articles' do
      VCR.use_cassette 'article/update_new_views' do
        # Try it with no articles.
        ViewImporter.update_new_views

        # Add an article.
        create(:article,
               id: 1,
               title: 'Wikipedia',
               namespace: 0)

        # Course, article-course, and revision are also needed.
        create(:course,
               id: 10001,
               start: Date.today - 1.month,
               end: Date.today + 1.month)
        create(:articles_course,
               id: 1,
               course_id: 10001,
               article_id: 1)
        create(:revision,
               article_id: 1)

        # Update again with this article.
        ViewImporter.update_new_views
        ViewImporter.update_all_views
      end
    end
  end
end
